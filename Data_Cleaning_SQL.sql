--Populate Property Address data

SELECT *
FROM [Nashville Housing Data]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT Nash1.ParcelID, Nash1.PropertyAddress, Nash2.ParcelID, Nash2.PropertyAddress, ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
FROM [Nashville Housing Data] Nash1
JOIN [Nashville Housing Data] Nash2
    ON Nash1.ParcelID = Nash2.ParcelID
    AND Nash1.UniqueID <> Nash2.UniqueID
WHERE Nash1.PropertyAddress IS NULL

UPDATE Nash1
SET Nash1.PropertyAddress = ISNULL(Nash1.PropertyAddress,Nash2.PropertyAddress)
FROM [Nashville Housing Data] Nash1
JOIN [Nashville Housing Data] Nash2
    ON Nash1.ParcelID = Nash2.ParcelID
    AND Nash1.UniqueID <> Nash2.UniqueID
WHERE Nash1.PropertyAddress IS NULL


--Breaking out Adress into individual column (Address, City, State)

SELECT PropertyAddress
FROM [Nashville Housing Data]

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM [Nashville Housing Data]

ALTER TABLE [Nashville Housing Data]
ADD PropertySplitAddress nvarchar(255), PropertySplitCity nvarchar(255)

UPDATE [Nashville Housing Data]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


-----------

SELECT OwnerAddress
FROM [Nashville Housing Data]

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Nashville Housing Data]

ALTER TABLE [Nashville Housing Data]
ADD OwnerSplitAddress nvarchar(255),
OwnerSplitCity nvarchar(255),
OwnerSplitState nvarchar(255)

UPDATE [Nashville Housing Data]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in 'SoldAsVacant' field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM [Nashville Housing Data]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END 
FROM [Nashville Housing Data]

UPDATE [Nashville Housing Data]
SET SoldAsVacant = CASE 
                    WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                   END 



--Remove Duplicates
WITH RowNumCTE AS
(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
FROM [Nashville Housing Data]
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


--Delete unused columns

ALTER TABLE [Nashville Housing Data]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT * 
FROM [Nashville Housing Data]
