/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleDataCleaning.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate2, CONVERT(date, Saledate)
From NashvilleDataCleaning.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter table NashvilleHousing
Add SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2 = Convert(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

--- Identifying Null Values

Select *
From NashvilleDataCleaning.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


--- Joining at ParcelID and filling rows with null values to have property addresses

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
From NashvilleDataCleaning.dbo.NashvilleHousing a
JOIN NashvilleDataCleaning.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET propertyaddress = ISNULL(a.propertyaddress,b.PropertyAddress)
From NashvilleDataCleaning.dbo.NashvilleHousing a
JOIN NashvilleDataCleaning.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleDataCleaning.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City

From NashvilleDataCleaning.dbo.NashvilleHousing

---Creating separate individual columns for address and city

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 

---See final result, two new columns for address and city
Select *

From NashvilleDataCleaning.dbo.NashvilleHousing

---Alternative method, using PARSENAME for columns separated into address, city, and state

Select OwnerAddress
From NashvilleDataCleaning.dbo.NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleDataCleaning.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleDataCleaning.dbo.NashvilleHousing


ALTER TABLE NashvilleDataCleaning.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleDataCleaning.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleDataCleaning.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleDataCleaning.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleDataCleaning.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleDataCleaning.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From NashvilleDataCleaning.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant) as #
From NashvilleDataCleaning.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleDataCleaning.dbo.NashvilleHousing


Update NashvilleDataCleaning.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleDataCleaning.dbo.NashvilleHousing

)

DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From NashvilleDataCleaning.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From NashvilleDataCleaning.dbo.NashvilleHousing


ALTER TABLE NashvilleDataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate














-----------------------------------------------------------------------------------------------










