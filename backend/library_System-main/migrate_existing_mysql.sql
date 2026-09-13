-- Manara LibrarySystem - migration from the pre-integration schema
-- Run once against the existing ubs_training database.
-- It is idempotent for ADD COLUMN operations and preserves existing rows.
SET @db := DATABASE();
-- author
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='author' AND COLUMN_NAME='nationality')=0, 'ALTER TABLE `author` ADD COLUMN `nationality` VARCHAR(120) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='author' AND COLUMN_NAME='image_data')=0, 'ALTER TABLE `author` ADD COLUMN `image_data` LONGBLOB NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='author' AND COLUMN_NAME='image_content_type')=0, 'ALTER TABLE `author` ADD COLUMN `image_content_type` VARCHAR(120) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- book
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='book' AND COLUMN_NAME='publisher')=0, 'ALTER TABLE `book` ADD COLUMN `publisher` VARCHAR(220) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='book' AND COLUMN_NAME='page_count')=0, 'ALTER TABLE `book` ADD COLUMN `page_count` INT NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='book' AND COLUMN_NAME='language')=0, 'ALTER TABLE `book` ADD COLUMN `language` VARCHAR(60) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='book' AND COLUMN_NAME='external_cover_url')=0, 'ALTER TABLE `book` ADD COLUMN `external_cover_url` VARCHAR(1000) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='book' AND COLUMN_NAME='metadata_source')=0, 'ALTER TABLE `book` ADD COLUMN `metadata_source` VARCHAR(80) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='book' AND COLUMN_NAME='borrowing_fee')=0, 'ALTER TABLE `book` ADD COLUMN `borrowing_fee` DECIMAL(19,2) NOT NULL DEFAULT 3.00', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- borrowing
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='borrowing' AND COLUMN_NAME='origin')=0, 'ALTER TABLE `borrowing` ADD COLUMN `origin` VARCHAR(30) NOT NULL DEFAULT ''COUNTER''', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='borrowing' AND COLUMN_NAME='fulfillment_method')=0, 'ALTER TABLE `borrowing` ADD COLUMN `fulfillment_method` VARCHAR(30) NOT NULL DEFAULT ''PICKUP''', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- digital_access
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='digital_access' AND COLUMN_NAME='paid_amount')=0, 'ALTER TABLE `digital_access` ADD COLUMN `paid_amount` DECIMAL(19,2) NOT NULL DEFAULT 0.00', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- payment
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='payment' AND COLUMN_NAME='provider')=0, 'ALTER TABLE `payment` ADD COLUMN `provider` VARCHAR(30) NOT NULL DEFAULT ''BRAINTREE''', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='payment' AND COLUMN_NAME='provider_transaction_id')=0, 'ALTER TABLE `payment` ADD COLUMN `provider_transaction_id` VARCHAR(180) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='payment' AND COLUMN_NAME='payment_method')=0, 'ALTER TABLE `payment` ADD COLUMN `payment_method` VARCHAR(30) NOT NULL DEFAULT ''CARD''', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='payment' AND COLUMN_NAME='channel')=0, 'ALTER TABLE `payment` ADD COLUMN `channel` VARCHAR(30) NOT NULL DEFAULT ''ONLINE''', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='payment' AND COLUMN_NAME='notes')=0, 'ALTER TABLE `payment` ADD COLUMN `notes` VARCHAR(1500) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- purchase
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='purchase' AND COLUMN_NAME='fulfillment_method')=0, 'ALTER TABLE `purchase` ADD COLUMN `fulfillment_method` VARCHAR(30) NOT NULL DEFAULT ''PICKUP''', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='purchase' AND COLUMN_NAME='fulfillment_status')=0, 'ALTER TABLE `purchase` ADD COLUMN `fulfillment_status` VARCHAR(40) NOT NULL DEFAULT ''AWAITING_PAYMENT''', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='purchase' AND COLUMN_NAME='delivery_address')=0, 'ALTER TABLE `purchase` ADD COLUMN `delivery_address` VARCHAR(1000) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='purchase' AND COLUMN_NAME='admin_notes')=0, 'ALTER TABLE `purchase` ADD COLUMN `admin_notes` VARCHAR(1500) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- reservation
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='reservation' AND COLUMN_NAME='paid_at')=0, 'ALTER TABLE `reservation` ADD COLUMN `paid_at` DATETIME(6) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='reservation' AND COLUMN_NAME='fulfillment_method')=0, 'ALTER TABLE `reservation` ADD COLUMN `fulfillment_method` VARCHAR(30) NOT NULL DEFAULT ''PICKUP''', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='reservation' AND COLUMN_NAME='fulfillment_status')=0, 'ALTER TABLE `reservation` ADD COLUMN `fulfillment_status` VARCHAR(40) NOT NULL DEFAULT ''WAITING_FOR_COPY''', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='reservation' AND COLUMN_NAME='delivery_address')=0, 'ALTER TABLE `reservation` ADD COLUMN `delivery_address` VARCHAR(1000) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='reservation' AND COLUMN_NAME='fee_amount')=0, 'ALTER TABLE `reservation` ADD COLUMN `fee_amount` DECIMAL(19,2) NOT NULL DEFAULT 0.00', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- room_reservation
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='room_reservation' AND COLUMN_NAME='base_price')=0, 'ALTER TABLE `room_reservation` ADD COLUMN `base_price` DECIMAL(19,2) NOT NULL DEFAULT 0.00', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='room_reservation' AND COLUMN_NAME='discount_percentage')=0, 'ALTER TABLE `room_reservation` ADD COLUMN `discount_percentage` DECIMAL(19,2) NOT NULL DEFAULT 0.00', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='room_reservation' AND COLUMN_NAME='discount_amount')=0, 'ALTER TABLE `room_reservation` ADD COLUMN `discount_amount` DECIMAL(19,2) NOT NULL DEFAULT 0.00', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='room_reservation' AND COLUMN_NAME='date_created')=0, 'ALTER TABLE `room_reservation` ADD COLUMN `date_created` DATETIME(6) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='room_reservation' AND COLUMN_NAME='last_updated')=0, 'ALTER TABLE `room_reservation` ADD COLUMN `last_updated` DATETIME(6) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- study_room
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='study_room' AND COLUMN_NAME='name')=0, 'ALTER TABLE `study_room` ADD COLUMN `name` VARCHAR(160) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='study_room' AND COLUMN_NAME='description')=0, 'ALTER TABLE `study_room` ADD COLUMN `description` TEXT NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='study_room' AND COLUMN_NAME='location')=0, 'ALTER TABLE `study_room` ADD COLUMN `location` VARCHAR(180) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='study_room' AND COLUMN_NAME='features')=0, 'ALTER TABLE `study_room` ADD COLUMN `features` TEXT NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='study_room' AND COLUMN_NAME='image_data')=0, 'ALTER TABLE `study_room` ADD COLUMN `image_data` LONGBLOB NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='study_room' AND COLUMN_NAME='image_content_type')=0, 'ALTER TABLE `study_room` ADD COLUMN `image_content_type` VARCHAR(120) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
-- user
SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@db AND TABLE_NAME='user' AND COLUMN_NAME='full_name')=0, 'ALTER TABLE `user` ADD COLUMN `full_name` VARCHAR(120) NULL', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- Make old Payment rows compatible with counter/Braintree flows.
ALTER TABLE `payment` MODIFY COLUMN `target_id` BIGINT NULL;
ALTER TABLE `payment` MODIFY COLUMN `card_brand` VARCHAR(80) NULL;
ALTER TABLE `payment` MODIFY COLUMN `card_last_four` VARCHAR(4) NULL;
ALTER TABLE `payment` MODIFY COLUMN `cardholder_name` VARCHAR(120) NULL;

-- Allow the longer Arabic content used by the redesigned forms.
ALTER TABLE `author` MODIFY COLUMN `biography` TEXT NULL;
ALTER TABLE `book` MODIFY COLUMN `description` TEXT NULL;
ALTER TABLE `category` MODIFY COLUMN `description` TEXT NULL;

-- Normalize old rows to the new business states.
UPDATE `room_reservation` SET `base_price` = COALESCE(NULLIF(`base_price`,0), `total_price`, 0), `discount_percentage`=COALESCE(`discount_percentage`,0), `discount_amount`=COALESCE(`discount_amount`,0), `date_created`=COALESCE(`date_created`, NOW(6)), `last_updated`=COALESCE(`last_updated`, NOW(6));
UPDATE `room_reservation` SET `status`='CANCELLED' WHERE `status`='PENDING';
UPDATE `purchase` SET `fulfillment_method` = CASE WHEN `purchase_type`='DIGITAL' THEN 'DIGITAL' ELSE COALESCE(NULLIF(`fulfillment_method`,''),'PICKUP') END;
UPDATE `purchase` SET `fulfillment_status` = CASE WHEN `status`='COMPLETED' AND `purchase_type`='DIGITAL' THEN 'DIGITAL_GRANTED' WHEN `status`='COMPLETED' THEN 'FULFILLED' WHEN `status`='CANCELLED' THEN 'CANCELLED' ELSE 'AWAITING_PAYMENT' END;
UPDATE `reservation` SET `fulfillment_status` = CASE WHEN `status`='WAITING' THEN 'WAITING_FOR_COPY' WHEN `status`='READY' THEN 'AWAITING_PAYMENT' WHEN `status`='FULFILLED' THEN 'HANDED_OVER' WHEN `status`='CANCELLED' THEN 'CANCELLED' ELSE COALESCE(NULLIF(`fulfillment_status`,''),'WAITING_FOR_COPY') END;
UPDATE `borrowing` SET `origin`=COALESCE(NULLIF(`origin`,''),'COUNTER'), `fulfillment_method`=COALESCE(NULLIF(`fulfillment_method`,''),'PICKUP');
UPDATE `digital_access` SET `paid_amount`=COALESCE(`paid_amount`,0);

-- New domain tables (holiday, discount_rule, checkout_intent) are created by Grails
-- because development dbCreate is 'update'. Fully stop and restart grails run-app after this migration.
