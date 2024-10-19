-- Data Cleaning using SQL

-- Checking the dataset 
SELECT *
FROM dbo.nashville_housing

-- Steps taken to clean the housing dataset------------------------------------------------------------------------------------------------------------

-- Standardize the date format in the SaleDate field (Changing from datetime format to date)

SELECT saledate
FROM dbo.nashville_housing

SELECT saledate, CAST(saledate AS DATE) AS SalesDateConverted
FROM dbo.nashville_housing; --Converted to normal date

ALTER TABLE dbo.nashville_housing
ADD SalesDateConverted DATE; -- Adding a new column to the table to store the converted date

UPDATE dbo.nashville_housing
SET SalesDateConverted = CAST(saledate AS DATE); -- Updating the added column with the normal date format

SELECT saledate, SalesDateConverted
FROM dbo.nashville_housing;

----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate the PropertyAddress field (The missing values in PropertyAddress field)

SELECT * FROM dbo.nashville_housing WHERE PropertyAddress is null; -- Checks the rows in the table where there is no value for Property Address

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.nashville_housing a
JOIN dbo.nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress is null; -- Self Join to join the table to itself 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) -- Populates the Property Address column where it is null
FROM dbo.nashville_housing a
JOIN dbo.nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress is null;

SELECT * FROM dbo.nashville_housing WHERE PropertyAddress is null;

------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking the PropertyAddress column into entity(Address & City)

SELECT LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) -1) AS Address, --Takes out the address from the PropertyAddress field
	 RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) AS City --Takes out the city from the propertyAdress field
FROM dbo.nashville_housing;

/*SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM dbo.nashville_housing; --- This code block does the same thing as the one above. */

ALTER TABLE dbo.nashville_housing
ADD PropertySplitAddress Nvarchar(255); -- Adding a new column to the table to store the Address

UPDATE dbo.nashville_housing
SET PropertySplitAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) -1); -- Updating the added column

ALTER TABLE dbo.nashville_housing
ADD PropertySplitCity Nvarchar(255); -- Adding a new column to the table to store the City

UPDATE dbo.nashville_housing
SET PropertySplitCity = RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)); -- Updating the added column

SELECT PropertySplitAddress, PropertySplitCity
FROM dbo.nashville_housing;

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking the OwnerAddress column into entity(Address, City, State)

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS Address, --Takes out the State from the OwnerAddress field
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS City, --Takes out the city from the OwnerAddress field
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State --Takes out the address from the OwnerAddress field
FROM dbo.nashville_housing;

ALTER TABLE dbo.nashville_housing
ADD OwnerSplitAddress Nvarchar(255); -- Adding a new column to the table to store the Owner's Address

UPDATE dbo.nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3); -- Updating the added column

ALTER TABLE dbo.nashville_housing
ADD OwnerSplitCity Nvarchar(255); -- Adding a new column to the table to store the Owner's City

UPDATE dbo.nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2); -- Updating the added column

ALTER TABLE dbo.nashville_housing
ADD OwnerSplitState Nvarchar(255); -- Adding a new column to the table to store the Owner's State

UPDATE dbo.nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1); -- Updating the added column

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM dbo.nashville_housing;

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Change the Y and N values to Yes and No in the SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2; -- Checks the number of distinct values and count for each in the SoldAsVacant column

SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM dbo.nashville_housing; --Changes the Y and N values to Yes and No in the SoldAsVacant column

UPDATE dbo.nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END
---------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (SELECT *, 
						ROW_NUMBER() OVER(
								PARTITION BY ParcelID,
											PropertyAddress,
											SalePrice,
											SaleDate,
											LegalReference
											ORDER BY UniqueID) row_num
FROM dbo.nashville_housing) 

DELETE
FROM RowNumCTE
WHERE row_num > 1 -- Deletes duplicate rows

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused columns 

SELECT *
FROM dbo.nashville_housing

ALTER TABLE dbo.nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
