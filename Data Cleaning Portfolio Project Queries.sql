/*

Cleaning Data in SQL Queries

*/

Select * 
From Portfolio_Project.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format


Select SaleDateConverted, CONVERT(Date, SaleDate) 
From Portfolio_Project.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)




------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select * 
From Portfolio_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]  <> B.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]  <> B.[UniqueID ]
where a.PropertyAddress is null


----------------------------------------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columsns(Address, City, State)

Select PropertyAddress 
From Portfolio_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From Portfolio_Project.dbo.NashvilleHousing


Select OwnerAddress
From Portfolio_Project.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From Portfolio_Project.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' THEN 'Yes'
         when SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
From Portfolio_Project.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
         when SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

---------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

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
				   
From Portfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
--Order by PropertyAddress


---------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate


--------------------------------------------------------------------------------------------------------------------------------



