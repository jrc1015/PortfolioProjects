SELECT * FROM public."NashvilleHousing"
ORDER BY "UniqueID_" ASC;

--CHANGE DATE FORMAT

SELECT
	to_char("SaleDate", 'MM-DD-YYYY') AS "SaleDateConverted"
FROM public."NashvilleHousing";

BEGIN Transaction;

ALTER TABLE "NashvilleHousing"
ADD "SaleDateConverted" VARCHAR;

UPDATE "NashvilleHousing"
SET "SaleDateConverted" = to_char("SaleDate", 'MM-DD-YYYY');

COMMIT Transaction;


--POPULATE PROPERTY ADDRESS

SELECT
	*
FROM
	public."NashvilleHousing"
--WHERE
	--"PropertyAddress" is null;
ORDER BY "ParcelID";

SELECT
	t1."ParcelID", t1."PropertyAddress", t2."ParcelID", t2."PropertyAddress",
	COALESCE (t1."PropertyAddress", t2."PropertyAddress")
FROM
	public."NashvilleHousing" t1
INNER JOIN public."NashvilleHousing" t2
	on t1."ParcelID" = t2."ParcelID"
	AND t1."UniqueID_" <> t2."UniqueID_"
WHERE t1."PropertyAddress" is null;

Begin Transaction;

UPDATE "NashvilleHousing" t1
SET "PropertyAddress" = COALESCE (t1."PropertyAddress", t2."PropertyAddress")
FROM
	public."NashvilleHousing" t2
WHERE t1."PropertyAddress" is null;

--TARGET TABLE MUST NOT REPEAT IN UPDATE CLAUSE FOR POSTGRES


END transaction;

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT
	"PropertyAddress"
FROM
	public."NashvilleHousing";

SELECT
	SUBSTRING("PropertyAddress", 1, POSITION(',' IN "PropertyAddress")-1) AS "Address",
	SUBSTRING("PropertyAddress", POSITION(',' IN "PropertyAddress")+1,
		LENGTH("PropertyAddress")) AS "Address"
FROM
	public."NashvilleHousing";

BEGIN Transaction;

ALTER TABLE "NashvilleHousing"
ADD "PropertySplitAddress" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "PropertySplitAddress" = SUBSTRING("PropertyAddress", 1, POSITION(',' IN "PropertyAddress")-1);

ALTER TABLE "NashvilleHousing"
ADD "PropertySplitCity" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "PropertySplitCity" = SUBSTRING("PropertyAddress", POSITION(',' IN "PropertyAddress")+1,
		LENGTH("PropertyAddress"));

COMMIT Transaction;

SELECT
	SPLIT_PART("OwnerAddress",',',1),
	SPLIT_PART("OwnerAddress",',',2),
	SPLIT_PART("OwnerAddress",',',3)
FROM public."NashvilleHousing";

BEGIN TRANSACTION;

ALTER TABLE "NashvilleHousing"
ADD "OwnerSplitAddress" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "OwnerSplitAddress" = SPLIT_PART("OwnerAddress",',',1);

ALTER TABLE "NashvilleHousing"
ADD "OwnerSplitCity" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "OwnerSplitCity" = SPLIT_PART("OwnerAddress",',',2);

ALTER TABLE "NashvilleHousing"
ADD "OwnerSplitState" VARCHAR(255);

UPDATE "NashvilleHousing"
SET "OwnerSplitState" = SPLIT_PART("OwnerAddress",',',3);

COMMIT Transaction;

--CHANGE TRUE/FALSE TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT("SoldAsVacant"), COUNT("SoldAsVacant")
FROM public."NashvilleHousing"
GROUP BY "SoldAsVacant"
ORDER BY 2;

SELECT CAST("SoldAsVacant" AS text),
	CASE WHEN "SoldAsVacant" = 'True' THEN 'YES'
	ELSE 'NO'
	END
FROM public."NashvilleHousing";


BEGIN TRANSACTION;

--UPDATE "NashvilleHousing"
--Set "SoldAsVacant"
--USING CASE
	--WHEN "SoldAsVacant" = 'True' THEN 'YES'
	--ELSE 'NO'
	--END;
--COULDN'T USE THIS FIRST STATEMENT DUE TO COLUMN BEING A BOOLEAN DATA TYPE AND CASE STATEMENT IS TEXT
ALTER TABLE "NashvilleHousing"
ALTER COLUMN "SoldAsVacant"
SET DATA TYPE text
USING CASE
    WHEN "SoldAsVacant" = 'True' THEN 'YES'
	WHEN "SoldAsVacant" = 'False' THEN 'NO'
	ELSE Null
	END;

COMMIT TRANSACTION;

--REMOVE DUPLICATES


BEGIN Transaction;

DELETE FROM "NashvilleHousing"
WHERE "UniqueID_" IN
    (SELECT "UniqueID_"
    FROM
        (SELECT "UniqueID_", ROW_NUMBER() OVER (
		PARTITION BY "ParcelID",
				 "PropertyAddress",
				 "SalePrice",
				 "SaleDate",
				 "LegalReference"
				 ORDER BY
					"UniqueID_"
					) row_num
        FROM "NashvilleHousing" ) t
        WHERE t.row_num > 1 );

COMMIT Transaction;


--DROP UNUSED COLUMNS

SELECT * FROM public."NashvilleHousing"

ALTER TABLE public."NashvilleHousing"
	DROP COLUMN "OwnerAddress",
	DROP COLUMN "TaxDistrict",
	DROP COLUMN "PropertyAddress",
	DROP COLUMN "SaleDate";
