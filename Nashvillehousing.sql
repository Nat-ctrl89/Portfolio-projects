----SQL Data cleaning

Select * from Portfolio_Project.dbo.Nashhousing$

----Standardize Date Format

Select SaleDate, Convert(Date, SaleDate) as Sale_date from Portfolio_Project.dbo.Nashhousing$

Update dbo.Nashhousing$
Set SaleDate = Convert(Date, SaleDate)

Select SaleDate from dbo.Nashhousing$

---- To Update properly (previous did not change anything)

Alter Table dbo.Nashhousing$
Add SaleDateConverted Date;

Update dbo.Nashhousing$
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted from Portfolio_Project.dbo.Nashhousing$

---------------------------------------------------------------------------------------------------------
----Populate Property Address data
Select * from Portfolio_Project.dbo.Nashhousing$
--where PropertyAddress is Null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project.dbo.Nashhousing$ as a
Join Portfolio_Project.dbo.Nashhousing$ as b
On a.ParcelID = b.ParcelID
And a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project.dbo.Nashhousing$ as a
Join Portfolio_Project.dbo.Nashhousing$ as b
On a.ParcelID = b.ParcelID
And a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null



--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress From Portfolio_Project.dbo.Nashhousing$

Select 
Substring (PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
Substring (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Portfolio_Project.dbo.Nashhousing$

Alter Table Portfolio_Project.dbo.Nashhousing$
Add PropertySplitAddress NVarchar (255);

Update Portfolio_Project.dbo.Nashhousing$
Set PropertySplitAddress = Substring (PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)


Alter Table Portfolio_Project.dbo.Nashhousing$
Add PropertySplitCity NVarchar (255);

Update Portfolio_Project.dbo.Nashhousing$
Set PropertySplitCity = Substring (PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

Select * from Portfolio_Project.dbo.Nashhousing$

--Simple way
Select 
Parsename(OwnerAddress,1)
FRom Portfolio_Project.dbo.Nashhousing$


--Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.dbo.Nashhousing$
Group by SoldAsVacant
order by 2

Select SoldAsVacant 
, Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
From Portfolio_Project.dbo.Nashhousing$

Update Portfolio_Project.dbo.Nashhousing$
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

--Remove Duplicates
With RowNumCTE As(
Select *,
ROW_NUMBER() Over (
Partition By ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
Order  by ParcelID ) as rownum

From Portfolio_Project.dbo.Nashhousing$

)

Delete
From RowNumCTE
where rownum>1

With RowNumCTE As(
Select *,
ROW_NUMBER() Over (
Partition By ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference
Order  by ParcelID ) as rownum

From Portfolio_Project.dbo.Nashhousing$

)

Select*
From RowNumCTE
where rownum>1
order by PropertyAddress

--Delete Unused Columns
Select * From Portfolio_Project.dbo.Nashhousing$

Alter table Portfolio_Project.dbo.Nashhousing$
Drop Column OwnerAddress, TaxDistrict,PropertyAddress

Alter table Portfolio_Project.dbo.Nashhousing$
Drop Column OwnerName, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms,FullBath,HalfBath

	
