
--פונקציה המחזירה טבלה
---------
--הפונקציה מחזירה את כל השטחים הפנויים שלא הושכרו בין התאריכים שהמשתמש מבקש.
alter FUNCTION GetAvailableSpace(@RentalStartDate DATE, @RentalEndDate DATE)
RETURNS TABLE
AS
RETURN
SELECT
    s.[Id],
    s.[FloorNumber],
    s.[NumberInFloor],
    s.[SizeInMeters]
FROM [dbo].[Spaces] s
WHERE NOT EXISTS (  
    SELECT *  
    FROM [dbo].[SpacesRental] sr  
    WHERE sr.Id_Spaces = s.Id  
    -- בדיקה אם יש חפיפה כלשהי בטווח התאריכים
    AND (
        @RentalStartDate BETWEEN sr.RentalStartDate AND sr.RentalEndDate  
        OR @RentalEndDate BETWEEN sr.RentalStartDate AND sr.RentalEndDate  
        OR (sr.RentalStartDate BETWEEN @RentalStartDate AND @RentalEndDate) -- מקרה שבו החוזה כולו בתוך הטווח שביקשנו
        OR (sr.RentalEndDate BETWEEN @RentalStartDate AND @RentalEndDate) -- מקרה שבו חוזה מתחיל לפני ונגמר אחרי
    )  
)
go

select * from dbo.GetAvailableSpace('2019-02-02','2029-02-10')--לבדוק מה לא תקין בתאריכים


----------------------------------------טריגר נוסף-----------------------
--הטריגר בודק אם אפשר להשכיר שטח חדש במרכז קניות, כולל בדיקת גודל מינימלי ומחיר.
--אם הכל תקין, הוא מאשר את ההשכרה ומציג את פרטי המחיר, ואם לא - הוא מונע את ההשכרה.

alter TRIGGER ValidateRental
ON SpacesRental
AFTER INSERT
AS
BEGIN
   --אם השטח קטן מ-5
    IF EXISTS (
        SELECT *
        FROM inserted i
        JOIN Spaces s ON i.Id_Spaces = s.Id
        WHERE s.SizeInMeters < 5.0
    )
    BEGIN
        PRINT 'שגיאה: לא ניתן להשכיר חנויות שגודלן קטן מ-5 מ"ר.'
        ROLLBACK TRANSACTION
        RETURN
    END;

    -- חישוב והדפסת מחירים
   WITH RentalDetails AS (
        SELECT
            i.Id_Spaces,
            s.SizeInMeters,
            dbo.storePrice(i.Id_Spaces) AS Price
        FROM inserted i
        JOIN Spaces s ON i.Id_Spaces = s.Id
    )
    SELECT
        'מחיר השכירות הצפוי: ' + CAST(Price AS VARCHAR(20)) AS PriceInfo,
        CASE WHEN SizeInMeters > 100.0
             THEN 'עדכון מחיר לחנויות גדולות'
             ELSE ''
        END AS SizeNote
    FROM RentalDetails

    -- עדכון מחיר אוטומטי לחנויות גדולות
    IF EXISTS (
        SELECT *
        FROM inserted i
        JOIN Spaces s ON i.Id_Spaces = s.Id
        WHERE s.SizeInMeters > 100.0
    )
    BEGIN
        EXEC UpdateRentByStoreType @newPricePerMeter = 120.00
    END
END


INSERT INTO SpacesRental (Id_Spaces, Id_Owners, RentalStartDate, RentalEndDate)
VALUES (17, 1, '2006-01-01', '2010-10-10')

--פונקציה המחזירה ערך סקלארי 
------
 alter function storePrice(@Id_Spaces int)
 returns float
 as
 begin
   declare @size float, @PricePerMeter float, @totalRent float
   select @size = s.SizeInMeters, @PricePerMeter=st.PricePerMeter
   from Spaces s join Settings st
   on s.Id = st.Id_Spaces
   where s.Id = @Id_Spaces
   set @totalRent = @size*@PricePerMeter
   return @totalRent
 end

 select dbo.storePrice(1) as totalRent

 
--פרוצדורה
-------
ALTER PROCEDURE UpdateRentByStoreType 
@newPricePerMeter float
AS
BEGIN
    --- עדכון לטבלת השטח לכל החנויות מהסוג המבוקש
    UPDATE Settings
    SET PricePerMeter = @newPricePerMeter
    WHERE Id_Spaces IN (
        SELECT s.Id AS RentalId
        FROM SpacesRental sr
        JOIN Spaces s 
		ON sr.Id_Spaces = s.Id
        JOIN Owners o 
		ON sr.Id_Owners = o.Id
        WHERE s.SizeInMeters > 10.00  -- רק חנויות עם שטח גדול מ-10 מ"ר
        AND s.Occipital_Area = 1   -- רק חנויות עורפיות
        AND Id_Owners IN(select Id_Owners from SpacesRental group by Id_Owners having count(*)>=2)
      
    )
    PRINT 'מחיר השכירות עודכן בהצלחה'
END


EXEC UpdateRentByStoreType 
    @newPricePerMeter =80.00

select * from SpacesRental
select * from Settings
select * from Spaces

--view
---------
alter VIEW AllStores 
AS
SELECT 
    s.Id AS SpaceID,--בוחר קוד שטח
    s.FloorNumber,--מספר קומה
    s.NumberInFloor,--מספר בתוך קומה
    s.SizeInMeters,--מחיר למטר
    st.Name AS StoreType,--סוג חנות
    o.FullName AS OwnerName,--שם בעל חנות
    sr.Store_Name AS StoreName,--שם חנות
    stp.PricePerMeter * s.SizeInMeters AS TotalRent,--מחיר סופי של השטח המסוים
    CASE 
        WHEN sr.Id IS NULL THEN 'פנוי להשכרה'--כותב אם פנוי
        ELSE 'מושכר'--או לא
    END AS RentalStatus,
    ROW_NUMBER() OVER (PARTITION BY s.FloorNumber ORDER BY s.SizeInMeters DESC) AS StoreRanking
  FROM Spaces s
   LEFT JOIN SpacesRental sr ON s.Id = sr.Id_Spaces
   LEFT JOIN StoreTypes st ON sr.Id_StoreTypes = st.Id
   LEFT JOIN Owners o ON sr.Id_Owners = o.Id
   LEFT JOIN Settings stp ON stp.Id_Spaces=s.Id -- חיבור להגדרות השכרה (מחיר למ"ר)

--מחזיר חנויות שהיו מושכרות בעבר וכרגע הן פנויות
SELECT * 
FROM AllStores
WHERE RentalStatus = 'פנוי להשכרה'
intersect
select *
from AllStores
where SpaceID in (
select distinct Id_Spaces from SpacesRental)

--סמן
-------
declare @FullName varchar(100) ,@Email_Address varchar(40), @daysLeft int, @message varchar(250),@subject varchar(100)
declare rentalCursor cursor for
select o.FullName , o.Email_Address, DATEDIFF(day,getdate(),sr.RentalEndDate)
from SpacesRental sr
join Owners o
on sr.Id_Owners=o.Id
where sr.RentalEndDate<= dateadd(month,3,getdate())
open rentalCursor 
fetch next from rentalCursor into @FullName, @Email_Address, @daysLeft
while @@FETCH_STATUS = 0
begin
set @message =
   case
      when @daysLeft > 30 then 'החוזה שלך עדיין בתוקף ל' +cast(@daysLeft as varchar) +'ימים. נא לעדכן בקרוב'
	  when @daysLeft between 1 and 30 then 'אזהרה: החוזה שלך עומד לפוג בעוד '+cast(@daysLeft as varchar) +'יום. נא לעדכנו במיידית'
	  else 'החוזה שלך פג, נא לפנות להנהלה בקשר להמשך החוזה'
   end

   set @subject =
    case
      when @daysLeft > 30 then 'חוזה בתוקף' 
	  when @daysLeft between 1 and 30 then 'תזכורת לחידוש החוזה '
	  else 'החוזה איננו בתוקף'
	end

 print 'seding email to '+@FullName +'('+@Email_Address+'):'+@message
 exec msdb.dbo.sp_send_dbmail
 @profile_name = 'Chani',
 @recipients = @Email_address,
 @subject = @subject,
 @body = @message
fetch next from rentalCursor into @FullName, @Email_Address, @daysLeft
end
close rentalCursor
deallocate  rentalCursor 

--תת שאילתה בselect

SELECT 
    sr.Store_Name AS 'שם החנות',
    o.FullName AS 'בעלים',
    
    -- תת-שאילתה שסופרת כמה חנויות נוספות יש לאותו בעלים
    (SELECT COUNT(*) 
     FROM SpacesRental sr 
     WHERE sr.Id_Owners = o.Id) AS 'סה"כ חנויות בבעלות'
  FROM SpacesRental sr
 JOIN Owners o ON sr.Id_Owners = o.Id










