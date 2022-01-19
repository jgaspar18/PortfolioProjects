/* 

Cleaning Data in SQL

*/

SELECT *
FROM Projects.dbo.NashvilleHousing

--------------------------------------------------

--Standardize Date

SELECT SaleDate, CONVERT(date,SaleDate)
FROM Projects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate DATE

----------------------------------------------------

--Populate Property Address Data

SELECT *
FROM Projects.dbo.NashvilleHousing
WHERE PropertyAddress is null

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Projects.dbo.NashvilleHousing a
JOIN Projects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Projects.dbo.NashvilleHousing a
JOIN Projects.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

-------------------------------------------------------

--Breaking out Address into individual columns 

Select 
SubString(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SubString(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM Projects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyStreet Nvarchar(255)

Update NashvilleHousing
Set PropertyStreet = SubString(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity Nvarchar(255)

Update NashvilleHousing
Set PropertyCity = SubString(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
FROM Projects.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Projects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnersStreet Nvarchar(255);

Update NashvilleHousing
SET OwnersStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnersCity Nvarchar(255);

Update NashvilleHousing
Set OwnersCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnersState Nvarchar(255);

Update NashvilleHousing
Set OwnersState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Projects.dbo.NashvilleHousing
GROUP by SoldasVacant
order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
FROM Projects.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
FROM Projects.dbo.NashvilleHousing
-----------------------------------------------------

--Remove Duplicates

With RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM Projects.dbo.NashvilleHousing
)
DELETE
FROM ROWNUMCTE
WHERE row_num > 1

SELECT *
FROM ROWNUMCTE
WHERE row_num > 1

-----------------------------------------------------------

--Delete Unused Columns

Select* 
FROM Projects.dbo.NashvilleHousing

ALTER TABLE Projects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress