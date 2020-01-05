-- phpMyAdmin SQL Dump
-- version 4.8.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Erstellungszeit: 31. Dez 2019 um 12:52
-- Server-Version: 10.1.37-MariaDB
-- PHP-Version: 7.3.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Datenbank: `eurofximport`
--
CREATE DATABASE IF NOT EXISTS `eurofximport` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `eurofximport`;

-- --------------------------------------------------------

--
-- Tabellenstruktur für Tabelle `currency_exchange`
--

DROP TABLE IF EXISTS `currency_exchange`;
CREATE TABLE `currency_exchange` (
  `exr_currency` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `exr_rate` float NOT NULL,
  `exr_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Daten für Tabelle `currency_exchange`
--

INSERT INTO `currency_exchange` (`exr_currency`, `exr_rate`, `exr_date`) VALUES
('AUD', 1.5992, '2019-12-30'),
('BGN', 1.9558, '2019-12-30'),
('BRL', 4.5128, '2019-12-30'),
('CAD', 1.4621, '2019-12-30'),
('CHF', 1.0871, '2019-12-30'),
('CNY', 7.8175, '2019-12-30'),
('CZK', 25.463, '2019-12-30'),
('DKK', 7.4697, '2019-12-30'),
('GBP', 0.85208, '2019-12-30'),
('HKD', 8.7133, '2019-12-30'),
('HRK', 7.4485, '2019-12-30'),
('HUF', 331.04, '2019-12-30'),
('IDR', 15565.7, '2019-12-30'),
('ILS', 3.8749, '2019-12-30'),
('INR', 79.812, '2019-12-30'),
('ISK', 135.8, '2019-12-30'),
('JPY', 122.19, '2019-12-30'),
('KRW', 1294.35, '2019-12-30'),
('MXN', 21.085, '2019-12-30'),
('MYR', 4.5948, '2019-12-30'),
('NOK', 9.846, '2019-12-30'),
('NZD', 1.6638, '2019-12-30'),
('PHP', 56.784, '2019-12-30'),
('PLN', 4.2567, '2019-12-30'),
('RON', 4.7821, '2019-12-30'),
('RUB', 69.2781, '2019-12-30'),
('SEK', 10.44, '2019-12-30'),
('SGD', 1.5088, '2019-12-30'),
('THB', 33.472, '2019-12-30'),
('TRY', 6.6567, '2019-12-30'),
('USD', 1.1189, '2019-12-30'),
('ZAR', 15.7398, '2019-12-30');

--
-- Indizes der exportierten Tabellen
--

--
-- Indizes für die Tabelle `currency_exchange`
--
ALTER TABLE `currency_exchange`
  ADD PRIMARY KEY (`exr_currency`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
