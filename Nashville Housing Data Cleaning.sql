/* 

Cleaning Data in SQL Queries 

*/

select * from [Portfolio Project].dbo.NashvilleHousing


-- Standardize Date Format

select SaleDateConverted, convert(Date,SaleDate)
from [Portfolio Project].dbo.NashvilleHousing


Update NashvilleHousing
set SaleDate = convert(Date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)


-- Populate Property Address data


select * from [Portfolio Project].dbo.NashvilleHousing
--where propertyaddress is null 
order by ParcelID 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress,b.propertyaddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
	on a.parcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 


update a 
set PropertyAddress = isnull(a.propertyaddress,b.propertyaddress)
from [Portfolio Project].dbo.NashvilleHousing a
join [Portfolio Project].dbo.NashvilleHousing b
	on a.parcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 



-- Breaking out Address into Individual Columns (Address, City, State)

 select propertyaddress from [Portfolio Project].dbo.NashvilleHousing
--where propertyaddress is null 
--order by ParcelID 

select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as address, 
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1 , len(propertyaddress))  as address
from [Portfolio Project].dbo.NashvilleHousing


Alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1)

Alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1 , len(propertyaddress))

select *
from [Portfolio Project].dbo.NashvilleHousing


select OwnerAddress
from [Portfolio Project].dbo.NashvilleHousing


select
parsename(replace(owneraddress, ',' ,'.'), 3),
parsename(replace(owneraddress, ',' ,'.'), 2),
parsename(replace(owneraddress, ',' ,'.'), 1)
from [Portfolio Project].dbo.NashvilleHousing

Alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = parsename(replace(owneraddress, ',' ,'.'), 3)

Alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = parsename(replace(owneraddress, ',' ,'.'), 2)

Alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = parsename(replace(owneraddress, ',' ,'.'), 1)


select *
from [Portfolio Project].dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct SoldAsVacant, count(soldasvacant)
from [Portfolio Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select soldasvacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No' else SoldAsVacant end 
from [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
set SoldAsVacant=case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No' else SoldAsVacant end 


-- Remove Duplicates

with rownumCTE as  (
select*,
ROW_NUMBER() over(
partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by 
				uniqueID
				) row_num
from [Portfolio Project].dbo.NashvilleHousing
)
select * from rownumCTE
where row_num>1
order by propertyaddress



-- Delete Unused Columns


select *
from [Portfolio Project].dbo.NashvilleHousing

alter table [Portfolio Project].dbo.NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress

alter table [Portfolio Project].dbo.NashvilleHousing
drop column saledate


--- Importing Data using OPENROWSET and BULK INSERT
