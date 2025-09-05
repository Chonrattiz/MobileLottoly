[mb68_66011212129.sql](https://github.com/user-attachments/files/22177120/mb68_66011212129.sql)# app_oracel999
#เพื่อน clone เอาได้เลย
git clone https://github.com/Chonrattiz/MobileLottoly.git
cd MobileLottoly
flutter pub get
flutter run
ไฟล์ดาต้าเบส
[Uploading mb68_66011212129.sql…]-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: Sep 05, 2025 at 05:54 PM
-- Server version: 9.3.0
-- PHP Version: 8.2.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mb68_66011212129`
--

-- --------------------------------------------------------

--
-- Table structure for table `lotto`
--

CREATE TABLE `lotto` (
  `lotto_id` int NOT NULL,
  `lotto_number` varchar(6) NOT NULL,
  `status` enum('sell','sold') NOT NULL DEFAULT 'sell',
  `price` decimal(10,2) DEFAULT '80.00',
  `created_by` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchases`
--

CREATE TABLE `purchases` (
  `purchase_id` int NOT NULL,
  `user_id` int NOT NULL,
  `total_price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `purchases_detail`
--

CREATE TABLE `purchases_detail` (
  `pd_id` int NOT NULL,
  `purchase_id` int NOT NULL,
  `lotto_id` int NOT NULL,
  `status` enum('ยัง','ถูก','ไม่ถูก') NOT NULL DEFAULT 'ยัง'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `rewards`
--

CREATE TABLE `rewards` (
  `reward_id` int NOT NULL,
  `lotto_id` int NOT NULL,
  `prize_money` decimal(10,2) NOT NULL,
  `prize_tier` int NOT NULL,
  `status` enum('ขึ้นเงิน','ยังไม่ขึ้นเงิน') NOT NULL DEFAULT 'ยังไม่ขึ้นเงิน'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('member','admin') NOT NULL DEFAULT 'member',
  `wallet` decimal(10,2) DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `email`, `password`, `role`, `wallet`) VALUES
(1, 'poder', 'poder@gmail.com', '$2a$10$YzBAsZacldRACvLg1dK/Wue8w2CEnIAk9iXoQMr8w46NWyBvHysf6', 'member', 5000.00);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `lotto`
--
ALTER TABLE `lotto`
  ADD PRIMARY KEY (`lotto_id`),
  ADD UNIQUE KEY `uq_lotto_number` (`lotto_number`),
  ADD KEY `idx_lotto_created_by` (`created_by`);

--
-- Indexes for table `purchases`
--
ALTER TABLE `purchases`
  ADD PRIMARY KEY (`purchase_id`),
  ADD KEY `fk_purchases_user` (`user_id`);

--
-- Indexes for table `purchases_detail`
--
ALTER TABLE `purchases_detail`
  ADD PRIMARY KEY (`pd_id`),
  ADD UNIQUE KEY `uq_pd_lotto` (`lotto_id`),
  ADD KEY `fk_pd_purchase` (`purchase_id`);

--
-- Indexes for table `rewards`
--
ALTER TABLE `rewards`
  ADD PRIMARY KEY (`reward_id`),
  ADD UNIQUE KEY `uq_reward_lotto` (`lotto_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `lotto`
--
ALTER TABLE `lotto`
  MODIFY `lotto_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchases`
--
ALTER TABLE `purchases`
  MODIFY `purchase_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `purchases_detail`
--
ALTER TABLE `purchases_detail`
  MODIFY `pd_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `rewards`
--
ALTER TABLE `rewards`
  MODIFY `reward_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `lotto`
--
ALTER TABLE `lotto`
  ADD CONSTRAINT `fk_lotto_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE RESTRICT;

--
-- Constraints for table `purchases`
--
ALTER TABLE `purchases`
  ADD CONSTRAINT `fk_purchases_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `purchases_detail`
--
ALTER TABLE `purchases_detail`
  ADD CONSTRAINT `fk_pd_lotto` FOREIGN KEY (`lotto_id`) REFERENCES `lotto` (`lotto_id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `fk_pd_purchase` FOREIGN KEY (`purchase_id`) REFERENCES `purchases` (`purchase_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Constraints for table `rewards`
--
ALTER TABLE `rewards`
  ADD CONSTRAINT `fk_reward_lotto` FOREIGN KEY (`lotto_id`) REFERENCES `lotto` (`lotto_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
()



โฟลเดอร์ back-end 
[api_oracel999.zip](https://github.com/user-attachments/files/22175719/api_oracel999.zip)
[API.MiniProMBA.zip](https://github.com/user-attachments/files/22175722/API.MiniProMBA.zip)
