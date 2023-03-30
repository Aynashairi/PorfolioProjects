--Cleaning Data in SQL Quries

Select * 
From portfolioProject.dbo.NashvilleHousingData

--------------------------------------------------------------------------------------------------------------------------

--Standardrize Date Format

Select SaleDateConverted, CONVERT(date,SaleDate)
From portfolioProject.dbo.NashvilleHousingData

UPDATE NashvilleHousingData
set SaleDate = CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousingData
add SaleDateConverted Date;

UPDATE NashvilleHousingData
set SaleDateConverted = CONVERT(date,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data

Select *
from portfolioProject.dbo.NashvilleHousingData
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolioProject.dbo.NashvilleHousingData a
Join portfolioProject.dbo.NashvilleHousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolioProject.dbo.NashvilleHousingData a
Join portfolioProject.dbo.NashvilleHousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -
--Breaking out Property Address into Indiviual Columns (Address, City, States)

select PropertyAddress
from portfolioProject.dbo.NashvilleHousingData


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from portfolioProject.dbo.NashvilleHousingData

-- adding column PropertySplitAddress and populating it

ALTER TABLE NashvilleHousingData
add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

-- adding column PropertySplitCity and populating it

ALTER TABLE NashvilleHousingData
add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousingData
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Breaking out Owner Address into Indiviual Columns (Address, City, States)

Select OwnerAddress
from portfolioProject.dbo.NashvilleHousingData


Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from portfolioProject.dbo.NashvilleHousingData

---Making New column OwnerSplitAddress and populating it

ALTER TABLE NashvilleHousingData
add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousingData
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

---Making New column OwnerSplitCity and populating it

ALTER TABLE NashvilleHousingData
add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousingData
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

---Making New column OwnerSplitState and populating it

ALTER TABLE NashvilleHousingData
add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousingData
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--change Y and N to Yes and No in "Sold as Vacant" field

Select distinct (SoldAsVacant), count(SoldAsVacant)
from portfolioProject.dbo.NashvilleHousingData
group by SoldAsVacant
order by 2

Select SoldAsVacant
,Case when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'No'
	  else SoldAsVacant
	  end
from portfolioProject.dbo.NashvilleHousingData

Update NashvilleHousingData
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
	  when SoldAsVacant = 'N' THEN 'No'
	  else SoldAsVacant
	  end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--remove duplicates

select *
from portfolioProject.dbo.NashvilleHousingData

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

From portfolioProject.dbo.NashvilleHousingData
--order by ParcelID
)


select *
from RowNumCTE
where row_num > 1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Delete unused columns

select *
from portfolioProject.dbo.NashvilleHousingData

ALTER TABLE portfolioProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, saleDate

ALTER TABLE portfolioProject.dbo.NashvilleHousingData
DROP COLUMN saleDate