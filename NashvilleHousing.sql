Cleaning in SQL Queries

*/

SELECT*
From PortfolioProject.dbo.NashvilleHousing
----------------------------------------------------------------
--Standardize Date Format

SELECT SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------------------------
--Populate Property Address data

SELECT *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAdress is null
Order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

----------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAdress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1 ) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

----------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order By 2

Select SoldAsVacant
,	CASE When SoldAsVacant = 'Y' THEN 'YES'
		 When SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Select SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
		 When SoldAsVacant = 'N' THEN 'NO'
		 ELSE SoldAsVacant
		 END

----------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS(
Select * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


----------------------------------------------------------------
--Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





