SELECT TOP (1000) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Case_Study_5].[dbo].[NashvilleHousing]
  
  -------------------------------------------------------------------------

-- Cleaning Data in SQL

SELECT *
FROM [Case_Study_5].[dbo].[NashvilleHousing]

---------------------------------------------------------------------------
-- Changing Sale Data to yyyy.mm.dd. This step wasn't needed as Date was already yyyy.mm.dd

SELECT Saledate, CONVERT(Date,Saledate)
FROM [Case_Study_5].[dbo].[NashvilleHousing]

UPDATE NashvilleHousing
set saledate = CONVERT(Date,Saledate)

-- OR

ALTER TABLE NashvilleHousing
ADD saledateConverted DATE;
UPDATE NashvilleHousing
set saledateConverted = CONVERT(Date,Saledate)

---------------------------------------------------------------------------
-- Populate Property Address data - Some properties had NULL PropertyAddresses. Which can't happen, even mobile homes have addresses.

SELECT *
FROM [Case_Study_5].[dbo].[NashvilleHousing]
WHERE PropertyAddress IS NULL

SELECT *
FROM [Case_Study_5].[dbo].[NashvilleHousing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- By doing this, we can see that some ParcelID correspond to certain PropertyAddress, and since there are duplicates, we can populate the NULL
-- Property Addresses of the NUlls with the Property Addresses that have the same ParcelID's.
-- Since if it has the same ParcelID it will be on the same location.

-- Now let's writte a Join code, that will join the table to itself through the ParcelID, while using the UniqueID as a key distinct carachter.

-- Step 1:

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM [Case_Study_5].[dbo].[NashvilleHousing] AS a
JOIN [Case_Study_5].[dbo].[NashvilleHousing] AS b
	ON	a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
WHERE a.propertyaddress IS NULL

-- Step 2: Make a column with the Property Address of b, to then UPDATE it to A

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Case_Study_5].[dbo].[NashvilleHousing] AS a
JOIN [Case_Study_5].[dbo].[NashvilleHousing] AS b
	ON	a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
WHERE a.propertyaddress IS NULL

-- Step 3: UPDATE the column from B to A

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM [Case_Study_5].[dbo].[NashvilleHousing] AS a
JOIN [Case_Study_5].[dbo].[NashvilleHousing] AS b
	ON	a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
WHERE a.propertyaddress IS NULL

-- Worked :)

---------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

-- Step 1: Looking at the table

SELECT PropertyAddress
FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- Step2 : For the Addresss we can see thats all columns seem to have a comma "," separating the address from the city.
-- Therefore we'll use them as delimiters to create a different column where we can store the City.
-- We'll use a substring and a character indexer.

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', Propertyaddress)) as Address
FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- This would give us Addresses with ',' at the end. For that not to happen we must include a -1 to the position of the SubString.

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', Propertyaddress)-1) as Address
FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- Comma gone. We have the Address, let's get the city.

-- Step 4: Now we want the rest. Meaning the string after the comma (the city).
-- For that, we'll do something similar, but change the starting position to whethever the CHARINDEX(',') appears.

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', Propertyaddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', Propertyaddress)+1, LEN(propertyaddress)) as City
FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- Works :)

-- Step 5: Let's create 2 new columns for the address and the city

ALTER TABLE [Case_Study_5].[dbo].[NashvilleHousing]
ADD PropertySplitAddress NVARCHAR(255); -- adds the table for the address

UPDATE [Case_Study_5].[dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) -- populates the table for the Address

ALTER TABLE [Case_Study_5].[dbo].[NashvilleHousing]
ADD PropertySplitCity NVARCHAR(255); -- adds the table for the City

UPDATE [Case_Study_5].[dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', Propertyaddress)+1, LEN(propertyaddress)) -- populates the table for the city

-- Let's check

SELECT 
PropertyAddress,
PropertySplitAddress,
PropertySplitCity
FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- Check's out :)

---------------------------------------------------------------------------
-- Now let's work on the OwnerAddress.

SELECT OwnerAddress
FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- As we can see, the OwnerAddress column has values that give us the address, city and State. We want those separte.
-- Let's fix that with PARSENAME, which is kind of an alternative to SUBSTRING and CHARINDEX
-- Step1:

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS Address, --PARSE looks for '.' instead of ','. So we have to tell it to look for ','.
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS State
FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- This is the line for the separation, now let's get the columns that we need to separate.
-- Step2:

ALTER TABLE [Case_Study_5].[dbo].[NashvilleHousing]
ADD OwnerSplitAddress NVARCHAR(255); -- adds the table for the address

UPDATE [Case_Study_5].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) -- populates the table for the Address

ALTER TABLE [Case_Study_5].[dbo].[NashvilleHousing]
ADD OwnerSplitCity NVARCHAR(255); -- adds the table for the City

UPDATE [Case_Study_5].[dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) -- populates the table for the city

ALTER TABLE [Case_Study_5].[dbo].[NashvilleHousing]
ADD OwnerSplitState NVARCHAR(255); -- adds the table for the State

UPDATE [Case_Study_5].[dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) -- populates the table for the State

-- let's Check

SELECT 
OwnerSplitAddress,
OwnerSplitCity,
OwnerSplitState
FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- Works :)

---------------------------------------------------------------------------
-- Change 0 and 1 to No and Yes in "sold as Vacant" field.

-- Step1: Check if there's more than just 1's and 0's on that column.

SELECT DISTINCT(SoldAsVacant)
FROM [Case_Study_5].[dbo].[NashvilleHousing] -- confirmed that we only have 0 and 1.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Case_Study_5].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant -- checking each count

-- Step2: Actually changing from 0/1 to No/Yes

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 1 THEN 'Yes'
	 WHEN SoldAsVacant = 0 THEN 'No'
	 END AS YesOrNo
FROM [Case_Study_5].[dbo].[NashvilleHousing]

UPDATE [Case_Study_5].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = '1' THEN 'Yes'
						WHEN SoldAsVacant = '0' THEN 'No'
						END
						FROM [Case_Study_5].[dbo].[NashvilleHousing] -- Conversion failed when converting the data type bit to the varchar value 'No'.

-- To solve that we change the data type of the column:

ALTER TABLE [Case_Study_5].[dbo].[NashvilleHousing] ALTER COLUMN SoldAsVacant VARCHAR(255)

-- And now we can run the code again.

UPDATE [Case_Study_5].[dbo].[NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = '1' THEN 'Yes'
						WHEN SoldAsVacant = '0' THEN 'No'
						END
						FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- Great Success!

---------------------------------------------------------------------------

-- Remove Duplicates
-- Step1:

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
	) AS Row_num
 FROM [Case_Study_5].[dbo].[NashvilleHousing])
 SELECT *
 FROM RowNumCTE

 -- Step2:

 WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
	) AS Row_num
 FROM [Case_Study_5].[dbo].[NashvilleHousing])
 SELECT *
 FROM RowNumCTE
 WHERE row_num > 1
 ORDER BY PropertyAddress

 -- Step3:

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) AS row_num
 FROM [Case_Study_5].[dbo].[NashvilleHousing])
 DELETE
 FROM RowNumCTE
 WHERE row_num > 1 -- Deleted the duplicates

 -- Let's check

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) AS row_num
 FROM [Case_Study_5].[dbo].[NashvilleHousing])
SELECT *
 FROM RowNumCTE
 WHERE row_num > 1

 -- Worked :)

---------------------------------------------------------------------------

-- Delete Unused Columns ( NEVER do this to raw data, this is just for Portfolio's sake).
-- The OwnerAddress ( the full one) is now redundant

-- Step 1: Check the hole table
SELECT *
FROM [Case_Study_5].[dbo].[NashvilleHousing]

-- Step2: Getting rid of unused columns

ALTER TABLE [Case_Study_5].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

