-- Paste the Syrabet SQL dump in this file, then run:
-- npm run db:down
-- npm run db:up
-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:8889
-- Généré le : jeu. 05 mars 2026 à 01:06
-- Version du serveur : 8.0.44
-- Version de PHP : 8.3.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `syrabet`
--

-- --------------------------------------------------------

--
-- Structure de la table `admin_admin_actions`
--

CREATE TABLE `admin_admin_actions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `admin_user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` text COLLATE utf8mb4_unicode_ci,
  `before_json` json DEFAULT NULL,
  `after_json` json DEFAULT NULL,
  `ip` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `admin_admin_users`
--

CREATE TABLE `admin_admin_users` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('ACTIVE','SUSPENDED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `permissions_json` json NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `admin_admin_users`
--
DELIMITER $$
CREATE TRIGGER `trg_admin_users_updated` BEFORE UPDATE ON `admin_admin_users` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `admin_risk_limits`
--

CREATE TABLE `admin_risk_limits` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `scope` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `scope_key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value_json` json NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `admin_risk_limits`
--

INSERT INTO `admin_risk_limits` (`id`, `scope`, `scope_key`, `name`, `value_json`, `status`, `created_at`, `updated_at`) VALUES
('afbcd94e-0cf8-11f1-88c1-a39a1dbe66c2', 'GLOBAL', NULL, 'DEFAULT_LIMITS', '{\"max_stake\": 500000, \"min_stake\": 200, \"max_payout\": 5000000, \"cooldown_place_bet_sec\": 3}', 'ACTIVE', '2026-02-21 13:45:40', '2026-02-21 13:45:40');

--
-- Déclencheurs `admin_risk_limits`
--
DELIMITER $$
CREATE TRIGGER `trg_risk_limits_updated` BEFORE UPDATE ON `admin_risk_limits` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `admin_roles`
--

CREATE TABLE `admin_roles` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `permissions_json` json NOT NULL,
  `is_system` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `admin_roles`
--

INSERT INTO `admin_roles` (`id`, `name`, `description`, `permissions_json`, `is_system`, `created_at`, `updated_at`) VALUES
('9c29a8c8-0f2b-11f1-aec8-9c25e612a812', 'SUPER_ADMIN', 'Accès total à la plateforme', '[\"*\"]', 1, '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
('9c29a99a-0f2b-11f1-aec8-9c25e612a812', 'RISK_MANAGER', 'Gestion des risques et limites', '[\"bets.view\", \"bets.void\", \"bets.limit\", \"users.view\", \"users.flag\", \"risk.*\", \"reports.view\"]', 1, '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
('9c29aa08-0f2b-11f1-aec8-9c25e612a812', 'TRADER', 'Gestion des cotes et marchés', '[\"events.*\", \"markets.*\", \"selections.*\", \"odds.*\", \"reports.view\"]', 1, '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
('9c29abd4-0f2b-11f1-aec8-9c25e612a812', 'CUSTOMER_SUPPORT', 'Support client', '[\"users.view\", \"users.edit\", \"bets.view\", \"wallet.view\", \"kyc.*\", \"bonuses.grant\", \"notifications.send\"]', 1, '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
('9c29ac2e-0f2b-11f1-aec8-9c25e612a812', 'FINANCE', 'Opérations financières', '[\"wallet.*\", \"payments.*\", \"withdrawals.*\", \"reports.financial\", \"affiliate.payouts\"]', 1, '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
('9c29ac88-0f2b-11f1-aec8-9c25e612a812', 'MARKETING', 'Promotions et contenu', '[\"promo.*\", \"bonuses.*\", \"notifications.*\", \"affiliate.view\", \"reports.marketing\"]', 1, '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
('9c29ace2-0f2b-11f1-aec8-9c25e612a812', 'ANALYST', 'Lecture seule pour analyse', '[\"*.view\", \"reports.*\"]', 1, '2026-02-21 13:45:40', '2026-02-21 13:45:40');

--
-- Déclencheurs `admin_roles`
--
DELIMITER $$
CREATE TRIGGER `trg_admin_roles_updated` BEFORE UPDATE ON `admin_roles` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `admin_v_kpi_daily`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `admin_v_kpi_daily` (
`accas_count` decimal(23,0)
,`active_bettors` bigint
,`avg_odds` decimal(22,8)
,`bets_count` bigint
,`cashout_count` decimal(23,0)
,`cashout_total` decimal(40,2)
,`day` date
,`ggr_estimated` decimal(41,2)
,`lost_count` decimal(23,0)
,`payouts_total` decimal(40,2)
,`singles_count` decimal(23,0)
,`stake_total` decimal(40,2)
,`won_count` decimal(23,0)
);

-- --------------------------------------------------------

--
-- Structure de la table `affiliate_affiliates`
--

CREATE TABLE `affiliate_affiliates` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `affiliate_affiliate_clicks`
--

CREATE TABLE `affiliate_affiliate_clicks` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `affiliate_link_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_hash` text COLLATE utf8mb4_unicode_ci,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `referrer` text COLLATE utf8mb4_unicode_ci,
  `utm_json` json DEFAULT NULL,
  `clicked_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `affiliate_affiliate_links`
--

CREATE TABLE `affiliate_affiliate_links` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `affiliate_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `landing_url` text COLLATE utf8mb4_unicode_ci,
  `campaign` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `affiliate_attributions`
--

CREATE TABLE `affiliate_attributions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `affiliate_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `click_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` enum('LAST_CLICK','FIRST_CLICK','LINEAR') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'LAST_CLICK',
  `attributed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `affiliate_commissions`
--

CREATE TABLE `affiliate_commissions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `affiliate_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `period` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_json` json NOT NULL,
  `amount` decimal(18,2) NOT NULL DEFAULT '0.00',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OPEN',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `affiliate_conversions`
--

CREATE TABLE `affiliate_conversions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `affiliate_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `conversion_type` enum('SIGNUP','FIRST_DEPOSIT','NET_REVENUE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `affiliate_payouts`
--

CREATE TABLE `affiliate_payouts` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `affiliate_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(18,2) NOT NULL,
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'XOF',
  `method` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_ref` text COLLATE utf8mb4_unicode_ci,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'REQUESTED',
  `requested_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `paid_at` timestamp NULL DEFAULT NULL,
  `meta_json` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `auth_kyc_profiles`
--

CREATE TABLE `auth_kyc_profiles` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` int NOT NULL DEFAULT '0',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `full_name` text COLLATE utf8mb4_unicode_ci,
  `dob` date DEFAULT NULL,
  `document_type` text COLLATE utf8mb4_unicode_ci,
  `document_no` text COLLATE utf8mb4_unicode_ci,
  `document_url` text COLLATE utf8mb4_unicode_ci,
  `submitted_at` timestamp NULL DEFAULT NULL,
  `verified_at` timestamp NULL DEFAULT NULL,
  `rejection_reason` text COLLATE utf8mb4_unicode_ci,
  `full_name_encrypted` text COLLATE utf8mb4_unicode_ci,
  `document_no_encrypted` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `auth_kyc_profiles`
--
DELIMITER $$
CREATE TRIGGER `trg_kyc_updated` BEFORE UPDATE ON `auth_kyc_profiles` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `auth_otp_codes`
--

CREATE TABLE `auth_otp_codes` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `destination` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Numéro de téléphone ou adresse email',
  `channel` enum('SMS','EMAIL','WHATSAPP') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SMS',
  `code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `purpose` enum('REGISTRATION','LOGIN','PASSWORD_RESET','WITHDRAWAL','PHONE_VERIFY','EMAIL_VERIFY') COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` int NOT NULL DEFAULT '0',
  `max_attempts` int NOT NULL DEFAULT '3',
  `status` enum('PENDING','VERIFIED','EXPIRED','BLOCKED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  `verified_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `auth_responsible_gaming`
--

CREATE TABLE `auth_responsible_gaming` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `limit_type` enum('DEPOSIT_DAILY','DEPOSIT_WEEKLY','DEPOSIT_MONTHLY','LOSS_DAILY','LOSS_WEEKLY','LOSS_MONTHLY','WAGER_DAILY','WAGER_WEEKLY','SESSION_DURATION_MINUTES','SELF_EXCLUSION','COOL_OFF') COLLATE utf8mb4_unicode_ci NOT NULL,
  `limit_value` decimal(18,2) DEFAULT NULL,
  `current_value` decimal(18,2) NOT NULL DEFAULT '0.00',
  `period_reset_at` timestamp NULL DEFAULT NULL,
  `status` enum('ACTIVE','PENDING_INCREASE','EXPIRED','REVOKED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `activated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `auth_responsible_gaming`
--
DELIMITER $$
CREATE TRIGGER `trg_rg_updated` BEFORE UPDATE ON `auth_responsible_gaming` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `auth_sessions`
--

CREATE TABLE `auth_sessions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `refresh_hash` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_hash` text COLLATE utf8mb4_unicode_ci,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL,
  `revoked_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `auth_users`
--

CREATE TABLE `auth_users` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `display_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `country` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'XOF',
  `locale` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'fr',
  `phone_verified` tinyint(1) NOT NULL DEFAULT '0',
  `email_verified` tinyint(1) NOT NULL DEFAULT '0',
  `email_encrypted` text COLLATE utf8mb4_unicode_ci,
  `email_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_encrypted` text COLLATE utf8mb4_unicode_ci,
  `phone_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('PENDING','ACTIVE','SUSPENDED','BANNED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `is_test` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `auth_users`
--
DELIMITER $$
CREATE TRIGGER `trg_users_updated` BEFORE UPDATE ON `auth_users` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `betting_bets`
--

CREATE TABLE `betting_bets` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `betslip_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('SINGLE','ACCA','SYSTEM') COLLATE utf8mb4_unicode_ci NOT NULL,
  `stake` decimal(18,2) NOT NULL,
  `total_odds` decimal(18,4) NOT NULL,
  `potential_payout` decimal(18,2) NOT NULL DEFAULT '0.00',
  `actual_payout` decimal(18,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'XOF',
  `status` enum('DRAFT','PLACED','PENDING','WON','LOST','VOID','CASHED_OUT','CANCELLED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT',
  `placed_at` timestamp NULL DEFAULT NULL,
  `settled_at` timestamp NULL DEFAULT NULL,
  `promo_redemption_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bonus_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_json` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ;

-- --------------------------------------------------------

--
-- Structure de la table `betting_betslips`
--

CREATE TABLE `betting_betslips` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OPEN',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `betting_betslips`
--
DELIMITER $$
CREATE TRIGGER `trg_betslips_updated` BEFORE UPDATE ON `betting_betslips` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `betting_bet_legs`
--

CREATE TABLE `betting_bet_legs` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `bet_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `event_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `market_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `selection_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `odds_locked` decimal(12,4) NOT NULL,
  `status` enum('PENDING','WON','LOST','VOID','CANCELLED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `result_json` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `betting_cashout_offers`
--

CREATE TABLE `betting_cashout_offers` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `bet_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(18,2) NOT NULL,
  `partial_min` decimal(18,2) DEFAULT NULL,
  `status` enum('AVAILABLE','ACCEPTED','EXPIRED','SUSPENDED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'AVAILABLE',
  `calculated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `betting_cashout_transactions`
--

CREATE TABLE `betting_cashout_transactions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `bet_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `offer_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(18,2) NOT NULL,
  `type` enum('FULL','PARTIAL') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'FULL',
  `remaining_stake` decimal(18,2) DEFAULT NULL,
  `remaining_potential_payout` decimal(18,2) DEFAULT NULL,
  `status` enum('PENDING','COMPLETED','FAILED','REVERSED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `betting_settlement_jobs`
--

CREATE TABLE `betting_settlement_jobs` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `event_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'QUEUED',
  `message` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `finished_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `br_entity_mapping`
--

CREATE TABLE `br_entity_mapping` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `entity_type` enum('SPORT','CATEGORY','TOURNAMENT','SEASON','COMPETITOR','MATCH','STAGE','PLAYER') COLLATE utf8mb4_unicode_ci NOT NULL,
  `betradar_urn` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'URN BetRadar complet (sr:competitor:44)',
  `betradar_id` int NOT NULL COMMENT 'ID numérique extrait du URN',
  `internal_table` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Table interne cible',
  `internal_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ID interne dans notre BDD',
  `name` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Nom pour référence rapide',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_synced_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `br_entity_mapping`
--
DELIMITER $$
CREATE TRIGGER `trg_br_entity_mapping_updated` BEFORE UPDATE ON `br_entity_mapping` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `br_feed_messages`
--

CREATE TABLE `br_feed_messages` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `producer_id` int NOT NULL,
  `message_type` enum('ODDS_CHANGE','BET_STOP','BET_START','FIXTURE_CHANGE','ROLLBACK_BET_SETTLEMENT','BET_SETTLEMENT','ALIVE','SNAPSHOT_COMPLETE','PRODUCER_UP','PRODUCER_DOWN','OTHER') COLLATE utf8mb4_unicode_ci NOT NULL,
  `betradar_event_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'URN de l événement (sr:match:XXXXX)',
  `event_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Notre event_id interne (si mappé)',
  `request_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Request ID BetRadar pour corrélation',
  `timestamp_ms` bigint NOT NULL COMMENT 'Timestamp du message en ms (epoch)',
  `processing_ms` int DEFAULT NULL COMMENT 'Temps de traitement en ms',
  `status` enum('RECEIVED','PROCESSED','SKIPPED','ERROR') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'RECEIVED',
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `payload_hash` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'SHA256 du payload pour dédup',
  `payload_size` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `br_feed_messages`
--
DELIMITER $$
CREATE TRIGGER `trg_br_feed_msg_counter` AFTER INSERT ON `br_feed_messages` FOR EACH ROW BEGIN
  UPDATE br_feed_state
  SET messages_received_today = messages_received_today + 1,
      last_message_at = CURRENT_TIMESTAMP
  WHERE id = 1;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `br_feed_state`
--

CREATE TABLE `br_feed_state` (
  `id` int NOT NULL DEFAULT '1',
  `connection_status` enum('CONNECTED','DISCONNECTED','RECOVERING') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DISCONNECTED',
  `connected_since` timestamp NULL DEFAULT NULL,
  `last_disconnect_at` timestamp NULL DEFAULT NULL,
  `disconnect_reason` text COLLATE utf8mb4_unicode_ci,
  `messages_received_today` bigint NOT NULL DEFAULT '0',
  `messages_processed_today` bigint NOT NULL DEFAULT '0',
  `messages_errors_today` bigint NOT NULL DEFAULT '0',
  `avg_processing_ms` decimal(8,2) DEFAULT NULL,
  `last_message_at` timestamp NULL DEFAULT NULL,
  `recovery_snapshot_ts` bigint DEFAULT NULL COMMENT 'Timestamp ms du dernier snapshot reçu',
  `config_json` json DEFAULT NULL COMMENT 'Config de connexion AMQP',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ;

--
-- Déchargement des données de la table `br_feed_state`
--

INSERT INTO `br_feed_state` (`id`, `connection_status`, `connected_since`, `last_disconnect_at`, `disconnect_reason`, `messages_received_today`, `messages_processed_today`, `messages_errors_today`, `avg_processing_ms`, `last_message_at`, `recovery_snapshot_ts`, `config_json`, `updated_at`) VALUES
(1, 'DISCONNECTED', NULL, NULL, NULL, 0, 0, 0, NULL, NULL, NULL, '{\"node_id\": 1, \"use_ssl\": true, \"amqp_host\": \"stgmq.betradar.com\", \"amqp_port\": 5671, \"amqp_vhost\": \"/unifiedfeed\", \"prefetch_count\": 100, \"recovery_window_minutes\": 180}', '2026-02-21 13:45:40');

--
-- Déclencheurs `br_feed_state`
--
DELIMITER $$
CREATE TRIGGER `trg_br_feed_state_updated` BEFORE UPDATE ON `br_feed_state` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `br_market_mapping`
--

CREATE TABLE `br_market_mapping` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `betradar_market_id` int NOT NULL COMMENT 'ID marché dans le feed BetRadar',
  `variant` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Variante du marché (sr:exact_goals:4+)',
  `sport_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Notre sport_id interne',
  `market_type_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Notre market_type_id interne',
  `market_type_code` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Code interne du market type (1X2)',
  `name_template` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Template de nom avec variables',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `br_market_mapping`
--

INSERT INTO `br_market_mapping` (`id`, `betradar_market_id`, `variant`, `sport_id`, `market_type_id`, `market_type_code`, `name_template`, `is_active`, `created_at`) VALUES
('9c2a9300-0f2b-11f1-aec8-9c25e612a812', 1, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, '1X2', '1X2', 1, '2026-02-21 13:45:40'),
('9c2a93e6-0f2b-11f1-aec8-9c25e612a812', 18, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'OVER_UNDER', 'Plus/Moins {total} buts', 1, '2026-02-21 13:45:40'),
('9c2a9468-0f2b-11f1-aec8-9c25e612a812', 29, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'BTTS', 'Les deux marquent', 1, '2026-02-21 13:45:40'),
('9c2a94c2-0f2b-11f1-aec8-9c25e612a812', 10, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'DOUBLE_CHANCE', 'Double Chance', 1, '2026-02-21 13:45:40'),
('9c2a951c-0f2b-11f1-aec8-9c25e612a812', 14, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'HANDICAP', 'Handicap européen {hcp}', 1, '2026-02-21 13:45:40'),
('9c2a9576-0f2b-11f1-aec8-9c25e612a812', 16, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'ASIAN_HANDICAP', 'Handicap asiatique {hcp}', 1, '2026-02-21 13:45:40'),
('9c2a95c6-0f2b-11f1-aec8-9c25e612a812', 41, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'CORRECT_SCORE', 'Score exact', 1, '2026-02-21 13:45:40'),
('9c2a9616-0f2b-11f1-aec8-9c25e612a812', 13, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'HT_FT', 'Mi-temps / Fin de match', 1, '2026-02-21 13:45:40'),
('9c2a9666-0f2b-11f1-aec8-9c25e612a812', 36, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'FIRST_GOALSCORER', 'Premier buteur', 1, '2026-02-21 13:45:40'),
('9c2a96b6-0f2b-11f1-aec8-9c25e612a812', 60, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'HALF_TIME_RESULT', 'Résultat mi-temps', 1, '2026-02-21 13:45:40'),
('9c2a9706-0f2b-11f1-aec8-9c25e612a812', 202, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'TOTAL_CORNERS', 'Total corners {total}', 1, '2026-02-21 13:45:40'),
('9c2a9756-0f2b-11f1-aec8-9c25e612a812', 203, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'TOTAL_CARDS', 'Total cartons {total}', 1, '2026-02-21 13:45:40'),
('9c2a97a6-0f2b-11f1-aec8-9c25e612a812', 12, NULL, 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', NULL, 'DRAW_NO_BET', 'Remboursé si nul', 1, '2026-02-21 13:45:40');

-- --------------------------------------------------------

--
-- Structure de la table `br_outcome_mapping`
--

CREATE TABLE `br_outcome_mapping` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `betradar_market_id` int NOT NULL,
  `betradar_outcome_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'ID outcome BetRadar (numérique ou URN)',
  `selection_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nom interne de la sélection',
  `display_name_template` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Template {$competitor1} etc.',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `br_outcome_mapping`
--

INSERT INTO `br_outcome_mapping` (`id`, `betradar_market_id`, `betradar_outcome_id`, `selection_name`, `display_name_template`, `created_at`) VALUES
('9c2ab36c-0f2b-11f1-aec8-9c25e612a812', 1, '1', 'HOME', '{$competitor1}', '2026-02-21 13:45:40'),
('9c2ab43e-0f2b-11f1-aec8-9c25e612a812', 1, '2', 'DRAW', 'Nul', '2026-02-21 13:45:40'),
('9c2ab4b6-0f2b-11f1-aec8-9c25e612a812', 1, '3', 'AWAY', '{$competitor2}', '2026-02-21 13:45:40'),
('9c2ab506-0f2b-11f1-aec8-9c25e612a812', 18, '12', 'OVER', 'Plus de {$total}', '2026-02-21 13:45:40'),
('9c2ab556-0f2b-11f1-aec8-9c25e612a812', 18, '13', 'UNDER', 'Moins de {$total}', '2026-02-21 13:45:40'),
('9c2ab5a6-0f2b-11f1-aec8-9c25e612a812', 29, '74', 'YES', 'Oui', '2026-02-21 13:45:40'),
('9c2ab5ec-0f2b-11f1-aec8-9c25e612a812', 29, '76', 'NO', 'Non', '2026-02-21 13:45:40'),
('9c2ab632-0f2b-11f1-aec8-9c25e612a812', 10, '9', '1X', '1X', '2026-02-21 13:45:40'),
('9c2ab682-0f2b-11f1-aec8-9c25e612a812', 10, '10', '12', '12', '2026-02-21 13:45:40'),
('9c2ab6c8-0f2b-11f1-aec8-9c25e612a812', 10, '11', 'X2', 'X2', '2026-02-21 13:45:40'),
('9c2ab718-0f2b-11f1-aec8-9c25e612a812', 12, '1714', 'HOME', '{$competitor1}', '2026-02-21 13:45:40'),
('9c2ab75e-0f2b-11f1-aec8-9c25e612a812', 12, '1715', 'AWAY', '{$competitor2}', '2026-02-21 13:45:40');

-- --------------------------------------------------------

--
-- Structure de la table `br_producers`
--

CREATE TABLE `br_producers` (
  `id` int NOT NULL COMMENT 'ID fixe assigné par BetRadar',
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `api_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `last_alive_at` timestamp NULL DEFAULT NULL COMMENT 'Dernier heartbeat reçu',
  `recovery_from_ts` bigint DEFAULT NULL COMMENT 'Timestamp ms début de recovery',
  `last_processed_msg_ts` bigint DEFAULT NULL COMMENT 'Timestamp ms du dernier message traité',
  `status` enum('ACTIVE','DOWN','RECOVERING') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `br_producers`
--

INSERT INTO `br_producers` (`id`, `name`, `description`, `api_url`, `is_active`, `last_alive_at`, `recovery_from_ts`, `last_processed_msg_ts`, `status`, `created_at`, `updated_at`) VALUES
(1, 'PREMATCH', 'Pre-match odds producer', NULL, 1, NULL, NULL, NULL, 'ACTIVE', '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
(3, 'LIVE', 'Live / In-play odds producer', NULL, 1, NULL, NULL, NULL, 'ACTIVE', '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
(4, 'BETPAL', 'Virtual sports producer', NULL, 1, NULL, NULL, NULL, 'ACTIVE', '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
(5, 'PREMIUM_CI', 'Premium Cricket producer', NULL, 1, NULL, NULL, NULL, 'ACTIVE', '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
(6, 'VF', 'Virtual Football producer', NULL, 1, NULL, NULL, NULL, 'ACTIVE', '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
(7, 'VBL', 'Virtual Basketball League producer', NULL, 1, NULL, NULL, NULL, 'ACTIVE', '2026-02-21 13:45:40', '2026-02-21 13:45:40'),
(8, 'VTO', 'Virtual Tennis Open producer', NULL, 1, NULL, NULL, NULL, 'ACTIVE', '2026-02-21 13:45:40', '2026-02-21 13:45:40');

--
-- Déclencheurs `br_producers`
--
DELIMITER $$
CREATE TRIGGER `trg_br_producers_updated` BEFORE UPDATE ON `br_producers` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `compliance_encryption_keys`
--

CREATE TABLE `compliance_encryption_keys` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `key_alias` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Nom logique de la clé (pii_key_v1, etc.)',
  `key_version` int NOT NULL DEFAULT '1',
  `algorithm` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'AES-256-GCM',
  `encrypted_key` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Clé chiffrée par la master key (KMS)',
  `status` enum('ACTIVE','ROTATED','REVOKED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `activated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `rotated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `notif_notifications`
--

CREATE TABLE `notif_notifications` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `channel` enum('SMS','EMAIL','PUSH','IN_APP') COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_json` json DEFAULT NULL,
  `status` enum('PENDING','QUEUED','SENT','DELIVERED','FAILED','READ') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `provider_ref` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `sent_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `notif_preferences`
--

CREATE TABLE `notif_preferences` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` enum('SMS','EMAIL','PUSH','IN_APP') COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `notif_preferences`
--
DELIMITER $$
CREATE TRIGGER `trg_notif_pref_updated` BEFORE UPDATE ON `notif_preferences` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `notif_templates`
--

CREATE TABLE `notif_templates` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `code` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` enum('SMS','EMAIL','PUSH','IN_APP') COLLATE utf8mb4_unicode_ci NOT NULL,
  `locale` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'fr',
  `subject` text COLLATE utf8mb4_unicode_ci,
  `body_template` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `variables_json` json DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_api_logs`
--

CREATE TABLE `obs_api_logs` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `method` enum('GET','POST','PUT','PATCH','DELETE') COLLATE utf8mb4_unicode_ci NOT NULL,
  `endpoint` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `route_pattern` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `query_params_json` json DEFAULT NULL,
  `request_size_bytes` int DEFAULT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_code` smallint NOT NULL,
  `response_size_bytes` int DEFAULT NULL,
  `duration_ms` int NOT NULL,
  `db_queries_count` smallint DEFAULT NULL,
  `db_time_ms` int DEFAULT NULL,
  `cache_hit` tinyint(1) DEFAULT NULL,
  `error_code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_bet_funnel`
--

CREATE TABLE `obs_bet_funnel` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `funnel_session_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `step` enum('EVENT_VIEW','MARKET_VIEW','ODDS_CLICK','BETSLIP_ADD','BETSLIP_OPEN','STAKE_ENTERED','PLACE_BET_CLICK','BET_CONFIRMED','BET_REJECTED','BETSLIP_ABANDONED') COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_order` tinyint NOT NULL,
  `event_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `market_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `selection_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bet_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `odds_shown` decimal(12,4) DEFAULT NULL,
  `stake_amount` decimal(18,2) DEFAULT NULL,
  `bet_type` enum('SINGLE','ACCA','SYSTEM') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `selections_count` int DEFAULT NULL,
  `rejection_reason` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_click_tracking`
--

CREATE TABLE `obs_click_tracking` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `page_view_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `click_type` enum('ODDS_SELECTION','ADD_TO_BETSLIP','REMOVE_FROM_BETSLIP','PLACE_BET','CASHOUT','DEPOSIT_CTA','WITHDRAW_CTA','PROMO_BANNER','PROMO_CODE_APPLY','SPORT_NAV','LEAGUE_NAV','EVENT_NAV','LIVE_TOGGLE','SEARCH_SUBMIT','LOGIN_SUBMIT','REGISTER_SUBMIT','MENU_TOGGLE','FILTER_APPLY','NOTIFICATION_CLICK','SHARE','OTHER') COLLATE utf8mb4_unicode_ci NOT NULL,
  `sport_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `market_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `selection_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `odds_at_click` decimal(12,4) DEFAULT NULL,
  `element_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `element_text` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `element_position` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `x_pct` decimal(5,2) DEFAULT NULL,
  `y_pct` decimal(5,2) DEFAULT NULL,
  `meta_json` json DEFAULT NULL,
  `clicked_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_device_fingerprints`
--

CREATE TABLE `obs_device_fingerprints` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `fingerprint_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_type` enum('DESKTOP','MOBILE','TABLET','APP_IOS','APP_ANDROID') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `browser` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `browser_version` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `os` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `os_version` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `screen_resolution` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timezone` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `language` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `canvas_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `webgl_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `audio_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fonts_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `plugins_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trust_score` decimal(5,2) DEFAULT NULL,
  `is_flagged` tinyint(1) NOT NULL DEFAULT '0',
  `flag_reason` text COLLATE utf8mb4_unicode_ci,
  `first_seen_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_seen_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `times_seen` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_error_logs`
--

CREATE TABLE `obs_error_logs` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `level` enum('DEBUG','INFO','WARN','ERROR','FATAL') COLLATE utf8mb4_unicode_ci NOT NULL,
  `source` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `service` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endpoint` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `stack` text COLLATE utf8mb4_unicode_ci,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payload_json` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_fraud_signals`
--

CREATE TABLE `obs_fraud_signals` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signal_type` enum('MULTI_ACCOUNT','VELOCITY_SPIKE','UNUSUAL_STAKE_PATTERN','GEO_ANOMALY','DEVICE_CHANGE','IP_PROXY_VPN','BONUS_ABUSE','ARB_BETTING','LATE_BETTING','STEAM_MOVE','DEPOSIT_WITHDRAW_CYCLE','IDENTITY_MISMATCH','CHARGEBACK_RISK','SELF_EXCLUSION_BYPASS') COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` enum('LOW','MEDIUM','HIGH','CRITICAL') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'MEDIUM',
  `score` decimal(5,2) NOT NULL DEFAULT '0.00',
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `evidence_json` json NOT NULL,
  `status` enum('NEW','REVIEWING','CONFIRMED','DISMISSED','ESCALATED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NEW',
  `reviewed_by` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `review_notes` text COLLATE utf8mb4_unicode_ci,
  `action_taken` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `detected_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_login_attempts`
--

CREATE TABLE `obs_login_attempts` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `identifier` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `method` enum('PASSWORD','OTP','SOCIAL','BIOMETRIC') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PASSWORD',
  `success` tinyint(1) NOT NULL DEFAULT '0',
  `failure_reason` enum('WRONG_PASSWORD','WRONG_OTP','ACCOUNT_NOT_FOUND','ACCOUNT_SUSPENDED','ACCOUNT_BANNED','SELF_EXCLUDED','COOL_OFF_ACTIVE','RATE_LIMITED','EXPIRED_OTP','DEVICE_NOT_RECOGNIZED') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `device_fingerprint_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attempted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_page_views`
--

CREATE TABLE `obs_page_views` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `page_url` varchar(2000) COLLATE utf8mb4_unicode_ci NOT NULL,
  `page_type` enum('HOME','SPORT','LEAGUE','EVENT','LIVE','BETSLIP','MY_BETS','WALLET','DEPOSIT','WITHDRAW','PROFILE','PROMO','SEARCH','RESULTS','REGISTER','LOGIN','KYC','FAQ','OTHER') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OTHER',
  `page_title` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sport_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `league_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `previous_page_url` varchar(2000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `view_sequence` int NOT NULL DEFAULT '1',
  `load_time_ms` int DEFAULT NULL,
  `time_on_page_seconds` int DEFAULT NULL,
  `scroll_depth_pct` tinyint DEFAULT NULL,
  `viewed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_search_logs`
--

CREATE TABLE `obs_search_logs` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `query` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `query_normalized` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `search_type` enum('GLOBAL','SPORT','EVENT','TEAM','LEAGUE') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'GLOBAL',
  `results_count` int NOT NULL DEFAULT '0',
  `results_shown_json` json DEFAULT NULL,
  `result_clicked_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `result_clicked_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `time_to_click_ms` int DEFAULT NULL,
  `searched_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_sessions_tracking`
--

CREATE TABLE `obs_sessions_tracking` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_type` enum('DESKTOP','MOBILE','TABLET','APP_IOS','APP_ANDROID') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `browser` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `os` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `screen_resolution` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referrer` text COLLATE utf8mb4_unicode_ci,
  `utm_source` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `utm_medium` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `utm_campaign` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `utm_content` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `affiliate_code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `landing_page` text COLLATE utf8mb4_unicode_ci,
  `pages_viewed` int NOT NULL DEFAULT '0',
  `clicks_count` int NOT NULL DEFAULT '0',
  `bets_placed` int NOT NULL DEFAULT '0',
  `deposits_made` int NOT NULL DEFAULT '0',
  `selections_added` int NOT NULL DEFAULT '0',
  `selections_removed` int NOT NULL DEFAULT '0',
  `started_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_activity_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ended_at` timestamp NULL DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `obs_user_events`
--

CREATE TABLE `obs_user_events` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `page` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `element` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `properties_json` json DEFAULT NULL,
  `device_json` json DEFAULT NULL,
  `locale` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_hash` text COLLATE utf8mb4_unicode_ci,
  `event_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `obs_v_fraud_pending`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `obs_v_fraud_pending` (
`action_taken` varchar(255)
,`balance_available` decimal(18,2)
,`description` text
,`detected_at` timestamp
,`email` varchar(255)
,`evidence_json` json
,`id` char(36)
,`phone` varchar(50)
,`review_notes` text
,`reviewed_at` timestamp
,`reviewed_by` char(36)
,`score` decimal(5,2)
,`session_id` varchar(255)
,`severity` enum('LOW','MEDIUM','HIGH','CRITICAL')
,`signal_type` enum('MULTI_ACCOUNT','VELOCITY_SPIKE','UNUSUAL_STAKE_PATTERN','GEO_ANOMALY','DEVICE_CHANGE','IP_PROXY_VPN','BONUS_ABUSE','ARB_BETTING','LATE_BETTING','STEAM_MOVE','DEPOSIT_WITHDRAW_CYCLE','IDENTITY_MISMATCH','CHARGEBACK_RISK','SELF_EXCLUSION_BYPASS')
,`status` enum('NEW','REVIEWING','CONFIRMED','DISMISSED','ESCALATED')
,`user_created_at` timestamp
,`user_id` char(36)
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `obs_v_funnel_daily`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `obs_v_funnel_daily` (
`day` date
,`step` enum('EVENT_VIEW','MARKET_VIEW','ODDS_CLICK','BETSLIP_ADD','BETSLIP_OPEN','STAKE_ENTERED','PLACE_BET_CLICK','BET_CONFIRMED','BET_REJECTED','BETSLIP_ABANDONED')
,`step_count` bigint
,`step_order` tinyint
,`unique_funnels` bigint
,`unique_users` bigint
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `obs_v_odds_clicks_by_sport`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `obs_v_odds_clicks_by_sport` (
`day` date
,`events_with_clicks` bigint
,`odds_clicks` bigint
,`sport_name` varchar(255)
,`unique_clickers` bigint
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `obs_v_top_pages`
-- (Voir ci-dessous la vue réelle)
--
CREATE TABLE `obs_v_top_pages` (
`avg_load_time_ms` decimal(14,4)
,`avg_scroll_depth` decimal(7,4)
,`avg_time_seconds` decimal(14,4)
,`page_type` enum('HOME','SPORT','LEAGUE','EVENT','LIVE','BETSLIP','MY_BETS','WALLET','DEPOSIT','WITHDRAW','PROFILE','PROMO','SEARCH','RESULTS','REGISTER','LOGIN','KYC','FAQ','OTHER')
,`unique_visitors` bigint
,`views` bigint
);

-- --------------------------------------------------------

--
-- Structure de la table `promo_bonuses`
--

CREATE TABLE `promo_bonuses` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `source` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(18,2) NOT NULL,
  `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `wagering_required` decimal(18,2) NOT NULL DEFAULT '0.00',
  `wagering_completed` decimal(18,2) NOT NULL DEFAULT '0.00',
  `meta_json` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `promo_promo_codes`
--

CREATE TABLE `promo_promo_codes` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `code` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('DEPOSIT_MATCH','FREEBET','ODDS_BOOST','CASHBACK') COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` decimal(18,2) NOT NULL,
  `start_at` timestamp NULL DEFAULT NULL,
  `end_at` timestamp NULL DEFAULT NULL,
  `max_uses` int DEFAULT NULL,
  `max_uses_per_user` int DEFAULT NULL,
  `min_deposit` decimal(18,2) DEFAULT NULL,
  `min_stake` decimal(18,2) DEFAULT NULL,
  `eligibility_json` json DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `promo_promo_codes`
--
DELIMITER $$
CREATE TRIGGER `trg_promo_codes_updated` BEFORE UPDATE ON `promo_promo_codes` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `promo_promo_redemptions`
--

CREATE TABLE `promo_promo_redemptions` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `promo_code_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('PENDING','APPLIED','REJECTED','CANCELLED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `redeemed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reference_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_json` json DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `promo_wagering_events`
--

CREATE TABLE `promo_wagering_events` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `bonus_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bet_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(18,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_countries`
--

CREATE TABLE `sportsbook_countries` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `code` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `sportsbook_countries`
--

INSERT INTO `sportsbook_countries` (`id`, `code`, `name`, `created_at`) VALUES
('afbcbfae-0cf8-11f1-88c1-a39a1dbe66c2', 'CI', 'Côte d\'Ivoire', '2026-02-21 13:45:40'),
('afbcc062-0cf8-11f1-88c1-a39a1dbe66c2', 'FR', 'France', '2026-02-21 13:45:40');

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_events`
--

CREATE TABLE `sportsbook_events` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `sport_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `league_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `home_team_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `away_team_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_type` enum('HEAD_TO_HEAD','MULTI_PARTICIPANT','OUTRIGHT') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'HEAD_TO_HEAD',
  `start_time` timestamp NOT NULL,
  `status` enum('SCHEDULED','LIVE','FINISHED','CANCELLED','POSTPONED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SCHEDULED',
  `live_clock` text COLLATE utf8mb4_unicode_ci,
  `score_json` json DEFAULT NULL,
  `result_confirmed` tinyint(1) NOT NULL DEFAULT '0',
  `meta_json` json DEFAULT NULL,
  `external_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `sportsbook_events`
--
DELIMITER $$
CREATE TRIGGER `trg_events_auto_name` BEFORE INSERT ON `sportsbook_events` FOR EACH ROW BEGIN
  IF NEW.name IS NULL
     AND NEW.event_type = 'HEAD_TO_HEAD'
     AND NEW.home_team_id IS NOT NULL
     AND NEW.away_team_id IS NOT NULL THEN
    SET NEW.name = CONCAT(
      (SELECT name FROM sportsbook_teams WHERE id = NEW.home_team_id),
      ' vs ',
      (SELECT name FROM sportsbook_teams WHERE id = NEW.away_team_id)
    );
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_events_updated` BEFORE UPDATE ON `sportsbook_events` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_event_participants`
--

CREATE TABLE `sportsbook_event_participants` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `event_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `team_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('HOME','AWAY','PARTICIPANT','DRAW_NUMBER') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PARTICIPANT',
  `display_order` int NOT NULL DEFAULT '0',
  `draw_number` int DEFAULT NULL,
  `result_position` int DEFAULT NULL,
  `result_status` enum('PENDING','FINISHED','DNF','DSQ','DNS') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `meta_json` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_leagues`
--

CREATE TABLE `sportsbook_leagues` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `sport_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `country_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `season` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `external_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_url` text COLLATE utf8mb4_unicode_ci,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_markets`
--

CREATE TABLE `sportsbook_markets` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `event_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `market_type_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `line` decimal(10,2) DEFAULT NULL,
  `margin` decimal(8,4) DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OPEN',
  `spec_json` json DEFAULT NULL,
  `result_json` json DEFAULT NULL,
  `settled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `sportsbook_markets`
--
DELIMITER $$
CREATE TRIGGER `trg_markets_updated` BEFORE UPDATE ON `sportsbook_markets` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_market_types`
--

CREATE TABLE `sportsbook_market_types` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `sport_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'NULL = type universel',
  `code` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `has_line` tinyint(1) NOT NULL DEFAULT '0',
  `selections_template_json` json DEFAULT NULL,
  `settlement_logic` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `sportsbook_market_types`
--

INSERT INTO `sportsbook_market_types` (`id`, `sport_id`, `code`, `name`, `description`, `has_line`, `selections_template_json`, `settlement_logic`, `display_order`, `status`, `created_at`) VALUES
('9c29f292-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', '1X2', 'Résultat du match', NULL, 0, '[\"Domicile\", \"Nul\", \"Extérieur\"]', 'MATCH_RESULT_1X2', 1, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f3be-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'OVER_UNDER', 'Plus/Moins de buts', NULL, 1, '[\"Plus de {{line}}\", \"Moins de {{line}}\"]', 'OVER_UNDER_GOALS', 2, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f45e-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'BTTS', 'Les deux équipes marquent', NULL, 0, '[\"Oui\", \"Non\"]', 'BOTH_TEAMS_SCORE', 3, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f4ea-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'DOUBLE_CHANCE', 'Double chance', NULL, 0, '[\"1X\", \"12\", \"X2\"]', 'DOUBLE_CHANCE', 4, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f56c-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'HANDICAP', 'Handicap européen', NULL, 1, '[\"Domicile {{line}}\", \"Nul\", \"Extérieur {{line}}\"]', 'EUROPEAN_HANDICAP', 5, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f5f8-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'ASIAN_HANDICAP', 'Handicap asiatique', NULL, 1, '[\"Domicile {{line}}\", \"Extérieur {{line}}\"]', 'ASIAN_HANDICAP', 6, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f666-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'CORRECT_SCORE', 'Score exact', NULL, 0, NULL, 'CORRECT_SCORE', 7, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f6f2-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'HT_FT', 'Mi-temps / Fin de match', NULL, 0, '[\"1/1\", \"1/X\", \"1/2\", \"X/1\", \"X/X\", \"X/2\", \"2/1\", \"2/X\", \"2/2\"]', 'HALF_TIME_FULL_TIME', 8, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f774-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'FIRST_GOALSCORER', 'Premier buteur', NULL, 0, NULL, 'FIRST_GOALSCORER', 9, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f7ec-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'HALF_TIME_RESULT', 'Résultat mi-temps', NULL, 0, '[\"Domicile\", \"Nul\", \"Extérieur\"]', 'MATCH_RESULT_1X2', 10, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f86e-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'TOTAL_CORNERS', 'Total corners', NULL, 1, '[\"Plus de {{line}}\", \"Moins de {{line}}\"]', 'OVER_UNDER_GENERIC', 11, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f8e6-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'TOTAL_CARDS', 'Total cartons', NULL, 1, '[\"Plus de {{line}}\", \"Moins de {{line}}\"]', 'OVER_UNDER_GENERIC', 12, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f972-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'DRAW_NO_BET', 'Remboursé si nul', NULL, 0, '[\"Domicile\", \"Extérieur\"]', 'DRAW_NO_BET', 13, 'ACTIVE', '2026-02-21 13:45:40'),
('9c29f9e0-0f2b-11f1-aec8-9c25e612a812', 'afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'WINNER', 'Vainqueur compétition', NULL, 0, NULL, 'OUTRIGHT_WINNER', 50, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a2adc-0f2b-11f1-aec8-9c25e612a812', 'afbca726-0cf8-11f1-88c1-a39a1dbe66c2', 'MONEY_LINE', 'Vainqueur du match', NULL, 0, '[\"Domicile\", \"Extérieur\"]', 'MONEY_LINE', 1, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a2ba4-0f2b-11f1-aec8-9c25e612a812', 'afbca726-0cf8-11f1-88c1-a39a1dbe66c2', 'POINT_SPREAD', 'Écart de points', NULL, 1, '[\"Domicile {{line}}\", \"Extérieur {{line}}\"]', 'POINT_SPREAD', 2, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a2c26-0f2b-11f1-aec8-9c25e612a812', 'afbca726-0cf8-11f1-88c1-a39a1dbe66c2', 'TOTAL_POINTS', 'Total de points', NULL, 1, '[\"Plus de {{line}}\", \"Moins de {{line}}\"]', 'OVER_UNDER_GENERIC', 3, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a2c9e-0f2b-11f1-aec8-9c25e612a812', 'afbca726-0cf8-11f1-88c1-a39a1dbe66c2', 'QUARTER_WINNER', 'Vainqueur quart-temps', NULL, 0, '[\"Domicile\", \"Extérieur\"]', 'MONEY_LINE', 4, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a2d20-0f2b-11f1-aec8-9c25e612a812', 'afbca726-0cf8-11f1-88c1-a39a1dbe66c2', 'HALF_WINNER', 'Vainqueur mi-temps', NULL, 0, '[\"Domicile\", \"Extérieur\"]', 'MONEY_LINE', 5, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a2d8e-0f2b-11f1-aec8-9c25e612a812', 'afbca726-0cf8-11f1-88c1-a39a1dbe66c2', 'ODD_EVEN', 'Total pair/impair', NULL, 0, '[\"Pair\", \"Impair\"]', 'ODD_EVEN', 6, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a2dfc-0f2b-11f1-aec8-9c25e612a812', 'afbca726-0cf8-11f1-88c1-a39a1dbe66c2', 'WINNER', 'Vainqueur compétition', NULL, 0, NULL, 'OUTRIGHT_WINNER', 50, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a47ba-0f2b-11f1-aec8-9c25e612a812', NULL, 'YES_NO', 'Oui / Non', NULL, 0, NULL, 'YES_NO', 90, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a4896-0f2b-11f1-aec8-9c25e612a812', NULL, 'WINNER_GENERIC', 'Vainqueur', NULL, 0, NULL, 'OUTRIGHT_WINNER', 91, 'ACTIVE', '2026-02-21 13:45:40'),
('9c2a48fa-0f2b-11f1-aec8-9c25e612a812', NULL, 'HEAD_TO_HEAD', 'Face à face', NULL, 0, NULL, 'MONEY_LINE', 92, 'ACTIVE', '2026-02-21 13:45:40');

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_odds_snapshots`
--

CREATE TABLE `sportsbook_odds_snapshots` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `selection_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `odds` decimal(12,4) NOT NULL,
  `source` text COLLATE utf8mb4_unicode_ci,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_selections`
--

CREATE TABLE `sportsbook_selections` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `market_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `odds` decimal(12,4) NOT NULL DEFAULT '1.0000',
  `result` enum('PENDING','WIN','LOSE','VOID','HALF_WIN','HALF_LOSE','PUSH') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `settled_at` timestamp NULL DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'OPEN',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `sportsbook_selections`
--
DELIMITER $$
CREATE TRIGGER `trg_selections_updated` BEFORE UPDATE ON `sportsbook_selections` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_sports`
--

CREATE TABLE `sportsbook_sports` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `sportsbook_sports`
--

INSERT INTO `sportsbook_sports` (`id`, `code`, `name`, `status`, `created_at`) VALUES
('afbca622-0cf8-11f1-88c1-a39a1dbe66c2', 'football', 'Football', 'ACTIVE', '2026-02-21 13:45:40'),
('afbca726-0cf8-11f1-88c1-a39a1dbe66c2', 'basketball', 'Basketball', 'ACTIVE', '2026-02-21 13:45:40');

-- --------------------------------------------------------

--
-- Structure de la table `sportsbook_teams`
--

CREATE TABLE `sportsbook_teams` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `sport_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('TEAM','INDIVIDUAL') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'TEAM',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `logo_url` text COLLATE utf8mb4_unicode_ci,
  `external_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ACTIVE',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `wallet_idempotency_keys`
--

CREATE TABLE `wallet_idempotency_keys` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `route` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_hash` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `response_json` json DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'IN_PROGRESS',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `wallet_ledger_entries`
--

CREATE TABLE `wallet_ledger_entries` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `wallet_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` enum('DEPOSIT','WITHDRAW','BET_STAKE','BET_WIN','BET_REFUND','BONUS_GRANTED','BONUS_EXPIRED','BONUS_CONVERTED','ADJUSTMENT','FEE','REFUND') COLLATE utf8mb4_unicode_ci NOT NULL,
  `direction` enum('CREDIT','DEBIT') COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(18,2) NOT NULL,
  `balance_after` decimal(18,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'XOF' COMMENT 'Dénormalisé depuis wallet pour les rapports',
  `reference_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reference_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `wallet_payments`
--

CREATE TABLE `wallet_payments` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `method` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'deposit',
  `amount` decimal(18,2) NOT NULL,
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'XOF',
  `status` enum('INITIATED','PENDING','SUCCESS','FAILED','CANCELLED','REFUNDED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'INITIATED',
  `provider_ref` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `meta_json` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `wallet_payments`
--
DELIMITER $$
CREATE TRIGGER `trg_payments_updated` BEFORE UPDATE ON `wallet_payments` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `wallet_wallets`
--

CREATE TABLE `wallet_wallets` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'XOF',
  `balance_available` decimal(18,2) NOT NULL DEFAULT '0.00',
  `balance_locked` decimal(18,2) NOT NULL DEFAULT '0.00',
  `balance_bonus` decimal(18,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `wallet_wallets`
--
DELIMITER $$
CREATE TRIGGER `trg_wallets_no_negative` BEFORE UPDATE ON `wallet_wallets` FOR EACH ROW BEGIN
  IF NEW.balance_available < 0
     OR NEW.balance_locked < 0
     OR NEW.balance_bonus < 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Negative balance not allowed';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_wallets_updated` BEFORE UPDATE ON `wallet_wallets` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `wallet_withdrawals`
--

CREATE TABLE `wallet_withdrawals` (
  `id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT (uuid()),
  `user_id` char(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `method` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `amount` decimal(18,2) NOT NULL,
  `currency` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'XOF',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'REQUESTED',
  `provider_ref` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci,
  `meta_json` json DEFAULT NULL,
  `requested_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déclencheurs `wallet_withdrawals`
--
DELIMITER $$
CREATE TRIGGER `trg_withdrawals_updated` BEFORE UPDATE ON `wallet_withdrawals` FOR EACH ROW BEGIN SET NEW.updated_at = CURRENT_TIMESTAMP; END
$$
DELIMITER ;

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `admin_admin_actions`
--
ALTER TABLE `admin_admin_actions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_admin_actions_created` (`created_at`),
  ADD KEY `idx_admin_actions_admin` (`admin_user_id`,`created_at`);

--
-- Index pour la table `admin_admin_users`
--
ALTER TABLE `admin_admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_admin_email` (`email`),
  ADD KEY `fk_admin_role` (`role_id`);

--
-- Index pour la table `admin_risk_limits`
--
ALTER TABLE `admin_risk_limits`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_risk_scope` (`scope`,`scope_key`,`name`);

--
-- Index pour la table `admin_roles`
--
ALTER TABLE `admin_roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_role_name` (`name`);

--
-- Index pour la table `affiliate_affiliates`
--
ALTER TABLE `affiliate_affiliates`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `affiliate_affiliate_clicks`
--
ALTER TABLE `affiliate_affiliate_clicks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_aff_clicks_link_time` (`affiliate_link_id`,`clicked_at`);

--
-- Index pour la table `affiliate_affiliate_links`
--
ALTER TABLE `affiliate_affiliate_links`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_aff_link_code` (`code`),
  ADD KEY `idx_aff_links_aff` (`affiliate_id`);

--
-- Index pour la table `affiliate_attributions`
--
ALTER TABLE `affiliate_attributions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_attrib_user` (`user_id`),
  ADD KEY `idx_attrib_aff` (`affiliate_id`,`attributed_at`),
  ADD KEY `fk_attrib_click` (`click_id`);

--
-- Index pour la table `affiliate_commissions`
--
ALTER TABLE `affiliate_commissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_aff_comm_period` (`affiliate_id`,`period`);

--
-- Index pour la table `affiliate_conversions`
--
ALTER TABLE `affiliate_conversions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_aff_conv_aff_time` (`affiliate_id`,`created_at`),
  ADD KEY `idx_aff_conv_user_time` (`user_id`,`created_at`);

--
-- Index pour la table `affiliate_payouts`
--
ALTER TABLE `affiliate_payouts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_aff_payouts_aff_time` (`affiliate_id`,`requested_at`);

--
-- Index pour la table `auth_kyc_profiles`
--
ALTER TABLE `auth_kyc_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_kyc_user` (`user_id`);

--
-- Index pour la table `auth_otp_codes`
--
ALTER TABLE `auth_otp_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_otp_dest_purpose` (`destination`,`purpose`,`created_at`),
  ADD KEY `idx_otp_user` (`user_id`,`created_at`),
  ADD KEY `idx_otp_expires` (`expires_at`);

--
-- Index pour la table `auth_responsible_gaming`
--
ALTER TABLE `auth_responsible_gaming`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_rg_user_type` (`user_id`,`limit_type`),
  ADD KEY `idx_rg_status` (`status`,`expires_at`);

--
-- Index pour la table `auth_sessions`
--
ALTER TABLE `auth_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sessions_user` (`user_id`,`created_at`),
  ADD KEY `idx_sessions_expires` (`expires_at`);

--
-- Index pour la table `auth_users`
--
ALTER TABLE `auth_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_email` (`email`),
  ADD UNIQUE KEY `uq_phone` (`phone`),
  ADD UNIQUE KEY `uq_username` (`username`),
  ADD KEY `idx_users_status_created` (`status`,`created_at`),
  ADD KEY `idx_users_email_hash` (`email_hash`),
  ADD KEY `idx_users_phone_hash` (`phone_hash`);

--
-- Index pour la table `betting_bets`
--
ALTER TABLE `betting_bets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bets_user_created` (`user_id`,`created_at`),
  ADD KEY `idx_bets_status_created` (`status`,`created_at`),
  ADD KEY `idx_bets_placed` (`placed_at`),
  ADD KEY `idx_bets_user_covering` (`user_id`,`created_at`,`type`,`stake`,`total_odds`,`potential_payout`,`actual_payout`,`status`),
  ADD KEY `fk_bets_betslip` (`betslip_id`),
  ADD KEY `fk_bets_bonus` (`bonus_id`),
  ADD KEY `fk_bets_promo_redemption` (`promo_redemption_id`);

--
-- Index pour la table `betting_betslips`
--
ALTER TABLE `betting_betslips`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_betslips_user` (`user_id`,`created_at`);

--
-- Index pour la table `betting_bet_legs`
--
ALTER TABLE `betting_bet_legs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_leg_bet_event` (`bet_id`,`event_id`),
  ADD KEY `idx_legs_bet` (`bet_id`),
  ADD KEY `idx_legs_event` (`event_id`),
  ADD KEY `idx_legs_selection` (`selection_id`),
  ADD KEY `idx_legs_bet_covering` (`bet_id`,`event_id`,`market_id`,`selection_id`,`odds_locked`,`status`),
  ADD KEY `idx_legs_event_status` (`event_id`,`status`,`bet_id`,`selection_id`,`odds_locked`),
  ADD KEY `fk_legs_market` (`market_id`);

--
-- Index pour la table `betting_cashout_offers`
--
ALTER TABLE `betting_cashout_offers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cashout_offer_bet` (`bet_id`,`status`),
  ADD KEY `idx_cashout_offer_expires` (`expires_at`),
  ADD KEY `idx_cashout_status_expires` (`status`,`expires_at`,`bet_id`,`amount`);

--
-- Index pour la table `betting_cashout_transactions`
--
ALTER TABLE `betting_cashout_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cashout_tx_bet` (`bet_id`),
  ADD KEY `idx_cashout_tx_user` (`user_id`,`created_at`),
  ADD KEY `fk_cashout_tx_offer` (`offer_id`);

--
-- Index pour la table `betting_settlement_jobs`
--
ALTER TABLE `betting_settlement_jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_settlement_jobs_created` (`created_at`),
  ADD KEY `idx_settlement_jobs_event` (`event_id`);

--
-- Index pour la table `br_entity_mapping`
--
ALTER TABLE `br_entity_mapping`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_br_urn` (`betradar_urn`),
  ADD UNIQUE KEY `uq_br_type_id` (`entity_type`,`betradar_id`),
  ADD KEY `idx_br_internal` (`internal_table`,`internal_id`),
  ADD KEY `idx_br_type_active` (`entity_type`,`is_active`),
  ADD KEY `idx_br_synced` (`last_synced_at`);

--
-- Index pour la table `br_feed_messages`
--
ALTER TABLE `br_feed_messages`
  ADD PRIMARY KEY (`id`,`created_at`),
  ADD KEY `idx_brfm_event_time` (`betradar_event_id`,`created_at`),
  ADD KEY `idx_brfm_type_time` (`message_type`,`created_at`),
  ADD KEY `idx_brfm_status` (`status`,`created_at`),
  ADD KEY `idx_brfm_producer` (`producer_id`,`created_at`),
  ADD KEY `idx_brfm_internal_evt` (`event_id`,`created_at`);

--
-- Index pour la table `br_feed_state`
--
ALTER TABLE `br_feed_state`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `br_market_mapping`
--
ALTER TABLE `br_market_mapping`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_br_market` (`betradar_market_id`,`variant`,`sport_id`),
  ADD KEY `idx_br_market_type` (`market_type_id`),
  ADD KEY `fk_brmm_sport` (`sport_id`);

--
-- Index pour la table `br_outcome_mapping`
--
ALTER TABLE `br_outcome_mapping`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_br_outcome` (`betradar_market_id`,`betradar_outcome_id`),
  ADD KEY `idx_br_outcome_market` (`betradar_market_id`);

--
-- Index pour la table `br_producers`
--
ALTER TABLE `br_producers`
  ADD PRIMARY KEY (`id`);

--
-- Index pour la table `compliance_encryption_keys`
--
ALTER TABLE `compliance_encryption_keys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_key_alias_version` (`key_alias`,`key_version`),
  ADD KEY `idx_key_status` (`status`,`key_alias`);

--
-- Index pour la table `notif_notifications`
--
ALTER TABLE `notif_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notif_user_status` (`user_id`,`status`,`created_at`),
  ADD KEY `idx_notif_status` (`status`,`created_at`),
  ADD KEY `idx_notif_template` (`template_id`);

--
-- Index pour la table `notif_preferences`
--
ALTER TABLE `notif_preferences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_notif_pref` (`user_id`,`channel`,`category`);

--
-- Index pour la table `notif_templates`
--
ALTER TABLE `notif_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_tpl_code_channel_locale` (`code`,`channel`,`locale`);

--
-- Index pour la table `obs_api_logs`
--
ALTER TABLE `obs_api_logs`
  ADD PRIMARY KEY (`id`,`created_at`),
  ADD KEY `idx_api_endpoint_time` (`route_pattern`,`created_at`),
  ADD KEY `idx_api_status_time` (`status_code`,`created_at`),
  ADD KEY `idx_api_user_time` (`user_id`,`created_at`),
  ADD KEY `idx_api_slow` (`duration_ms`,`created_at`),
  ADD KEY `idx_api_errors` (`status_code`,`route_pattern`,`created_at`);

--
-- Index pour la table `obs_bet_funnel`
--
ALTER TABLE `obs_bet_funnel`
  ADD PRIMARY KEY (`id`,`created_at`),
  ADD KEY `idx_bf_funnel_session` (`funnel_session_id`,`step_order`),
  ADD KEY `idx_bf_session` (`session_id`,`created_at`),
  ADD KEY `idx_bf_user_time` (`user_id`,`created_at`),
  ADD KEY `idx_bf_step_time` (`step`,`created_at`),
  ADD KEY `idx_bf_event` (`event_id`,`created_at`),
  ADD KEY `idx_bf_rejection` (`rejection_reason`,`created_at`);

--
-- Index pour la table `obs_click_tracking`
--
ALTER TABLE `obs_click_tracking`
  ADD PRIMARY KEY (`id`,`clicked_at`),
  ADD KEY `idx_ct_session` (`session_id`,`clicked_at`),
  ADD KEY `idx_ct_user_time` (`user_id`,`clicked_at`),
  ADD KEY `idx_ct_type_time` (`click_type`,`clicked_at`),
  ADD KEY `idx_ct_selection` (`selection_id`,`clicked_at`),
  ADD KEY `idx_ct_event` (`event_id`,`clicked_at`),
  ADD KEY `idx_ct_sport` (`sport_id`,`clicked_at`);

--
-- Index pour la table `obs_device_fingerprints`
--
ALTER TABLE `obs_device_fingerprints`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_df_fingerprint` (`fingerprint_hash`),
  ADD KEY `idx_df_user` (`user_id`,`first_seen_at`),
  ADD KEY `idx_df_flagged` (`is_flagged`,`last_seen_at`),
  ADD KEY `idx_df_trust` (`trust_score`),
  ADD KEY `idx_df_fingerprint_user` (`fingerprint_hash`,`user_id`,`last_seen_at`);

--
-- Index pour la table `obs_error_logs`
--
ALTER TABLE `obs_error_logs`
  ADD PRIMARY KEY (`id`,`created_at`),
  ADD KEY `idx_error_logs_user_time` (`user_id`,`created_at`),
  ADD KEY `idx_error_logs_level_time` (`level`,`created_at`);

--
-- Index pour la table `obs_fraud_signals`
--
ALTER TABLE `obs_fraud_signals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_fs_user_time` (`user_id`,`detected_at`),
  ADD KEY `idx_fs_type_status` (`signal_type`,`status`),
  ADD KEY `idx_fs_severity_status` (`severity`,`status`,`detected_at`),
  ADD KEY `idx_fs_status` (`status`,`detected_at`),
  ADD KEY `fk_fs_reviewer` (`reviewed_by`);

--
-- Index pour la table `obs_login_attempts`
--
ALTER TABLE `obs_login_attempts`
  ADD PRIMARY KEY (`id`,`attempted_at`),
  ADD KEY `idx_la_identifier_time` (`identifier`,`attempted_at`),
  ADD KEY `idx_la_ip_time` (`ip_hash`(64),`attempted_at`),
  ADD KEY `idx_la_user_time` (`user_id`,`attempted_at`),
  ADD KEY `idx_la_failed` (`success`,`attempted_at`);

--
-- Index pour la table `obs_page_views`
--
ALTER TABLE `obs_page_views`
  ADD PRIMARY KEY (`id`,`viewed_at`),
  ADD KEY `idx_pv_session` (`session_id`,`view_sequence`),
  ADD KEY `idx_pv_user_time` (`user_id`,`viewed_at`),
  ADD KEY `idx_pv_page_type` (`page_type`,`viewed_at`),
  ADD KEY `idx_pv_sport` (`sport_id`,`viewed_at`),
  ADD KEY `idx_pv_event` (`event_id`,`viewed_at`);

--
-- Index pour la table `obs_search_logs`
--
ALTER TABLE `obs_search_logs`
  ADD PRIMARY KEY (`id`,`searched_at`),
  ADD KEY `idx_sl_user_time` (`user_id`,`searched_at`),
  ADD KEY `idx_sl_query_norm` (`query_normalized`,`searched_at`),
  ADD KEY `idx_sl_type` (`search_type`,`searched_at`),
  ADD KEY `idx_sl_no_results` (`results_count`,`searched_at`);

--
-- Index pour la table `obs_sessions_tracking`
--
ALTER TABLE `obs_sessions_tracking`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_ost_session` (`session_id`),
  ADD KEY `idx_ost_user_started` (`user_id`,`started_at`),
  ADD KEY `idx_ost_started` (`started_at`),
  ADD KEY `idx_ost_device_started` (`device_type`,`started_at`),
  ADD KEY `idx_ost_utm_source` (`utm_source`,`started_at`),
  ADD KEY `idx_ost_affiliate` (`affiliate_code`,`started_at`);

--
-- Index pour la table `obs_user_events`
--
ALTER TABLE `obs_user_events`
  ADD PRIMARY KEY (`id`,`event_time`),
  ADD KEY `idx_user_events_user_time` (`user_id`,`event_time`),
  ADD KEY `idx_user_events_name_time` (`event_name`,`event_time`);

--
-- Index pour la table `promo_bonuses`
--
ALTER TABLE `promo_bonuses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_bonus_user` (`user_id`,`granted_at`),
  ADD KEY `idx_bonus_status` (`status`),
  ADD KEY `idx_bonus_user_covering` (`user_id`,`status`,`expires_at`,`amount`,`wagering_required`,`wagering_completed`);

--
-- Index pour la table `promo_promo_codes`
--
ALTER TABLE `promo_promo_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_promo_code` (`code`),
  ADD KEY `idx_promo_status` (`status`);

--
-- Index pour la table `promo_promo_redemptions`
--
ALTER TABLE `promo_promo_redemptions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_promo_redeem` (`promo_code_id`,`user_id`,`reference_type`,`reference_id`),
  ADD KEY `idx_redemptions_user` (`user_id`,`redeemed_at`),
  ADD KEY `idx_redemptions_code` (`promo_code_id`,`redeemed_at`);

--
-- Index pour la table `promo_wagering_events`
--
ALTER TABLE `promo_wagering_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_wagering_bonus_created` (`bonus_id`,`created_at`),
  ADD KEY `fk_wager_bet` (`bet_id`);

--
-- Index pour la table `sportsbook_countries`
--
ALTER TABLE `sportsbook_countries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_country_code` (`code`);

--
-- Index pour la table `sportsbook_events`
--
ALTER TABLE `sportsbook_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_events_status_start` (`status`,`start_time`),
  ADD KEY `idx_events_league_start` (`league_id`,`start_time`),
  ADD KEY `idx_events_external` (`external_id`),
  ADD KEY `idx_events_sport_status_start` (`sport_id`,`status`,`start_time`,`league_id`,`home_team_id`,`away_team_id`,`name`,`event_type`),
  ADD KEY `idx_events_live` (`status`,`sport_id`,`start_time`,`league_id`),
  ADD KEY `fk_events_home` (`home_team_id`),
  ADD KEY `fk_events_away` (`away_team_id`);
ALTER TABLE `sportsbook_events` ADD FULLTEXT KEY `ft_events_name` (`name`);

--
-- Index pour la table `sportsbook_event_participants`
--
ALTER TABLE `sportsbook_event_participants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_ep_event_team` (`event_id`,`team_id`),
  ADD KEY `idx_ep_event_order` (`event_id`,`display_order`),
  ADD KEY `idx_ep_team` (`team_id`);

--
-- Index pour la table `sportsbook_leagues`
--
ALTER TABLE `sportsbook_leagues`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_leagues_sport_country` (`sport_id`,`country_id`),
  ADD KEY `idx_leagues_external` (`external_id`),
  ADD KEY `fk_leagues_country` (`country_id`);
ALTER TABLE `sportsbook_leagues` ADD FULLTEXT KEY `ft_leagues_name` (`name`);

--
-- Index pour la table `sportsbook_markets`
--
ALTER TABLE `sportsbook_markets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_markets_event` (`event_id`),
  ADD KEY `idx_markets_type` (`market_type_id`),
  ADD KEY `idx_markets_event_status_type` (`event_id`,`status`,`market_type_id`);

--
-- Index pour la table `sportsbook_market_types`
--
ALTER TABLE `sportsbook_market_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_mt_sport_code` (`sport_id`,`code`),
  ADD KEY `idx_mt_sport_order` (`sport_id`,`display_order`);

--
-- Index pour la table `sportsbook_odds_snapshots`
--
ALTER TABLE `sportsbook_odds_snapshots`
  ADD PRIMARY KEY (`id`,`ts`),
  ADD KEY `idx_odds_selection_ts` (`selection_id`,`ts`);

--
-- Index pour la table `sportsbook_selections`
--
ALTER TABLE `sportsbook_selections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_selections_market` (`market_id`),
  ADD KEY `idx_selections_result` (`result`),
  ADD KEY `idx_selections_market_covering` (`market_id`,`status`,`name`,`odds`,`result`);

--
-- Index pour la table `sportsbook_sports`
--
ALTER TABLE `sportsbook_sports`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_sport_code` (`code`);

--
-- Index pour la table `sportsbook_teams`
--
ALTER TABLE `sportsbook_teams`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_teams_sport` (`sport_id`),
  ADD KEY `idx_teams_external` (`external_id`),
  ADD KEY `fk_teams_country` (`country_id`);
ALTER TABLE `sportsbook_teams` ADD FULLTEXT KEY `ft_teams_name` (`name`,`short_name`);

--
-- Index pour la table `wallet_idempotency_keys`
--
ALTER TABLE `wallet_idempotency_keys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_idem_key` (`key`),
  ADD KEY `idx_idem_user` (`user_id`),
  ADD KEY `idx_idem_expires` (`expires_at`);

--
-- Index pour la table `wallet_ledger_entries`
--
ALTER TABLE `wallet_ledger_entries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ledger_wallet_created` (`wallet_id`,`created_at`),
  ADD KEY `idx_ledger_ref` (`reference_type`,`reference_id`),
  ADD KEY `idx_ledger_wallet_covering` (`wallet_id`,`created_at`,`type`,`direction`,`amount`,`balance_after`,`reference_type`,`reference_id`);

--
-- Index pour la table `wallet_payments`
--
ALTER TABLE `wallet_payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_payments_provider_ref` (`provider`,`provider_ref`),
  ADD KEY `idx_payments_user_created` (`user_id`,`created_at`),
  ADD KEY `idx_payments_status_created` (`status`,`created_at`);

--
-- Index pour la table `wallet_wallets`
--
ALTER TABLE `wallet_wallets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_wallet_user_currency` (`user_id`,`currency`),
  ADD KEY `idx_wallets_user` (`user_id`);

--
-- Index pour la table `wallet_withdrawals`
--
ALTER TABLE `wallet_withdrawals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_withdrawals_user` (`user_id`,`requested_at`),
  ADD KEY `idx_withdrawals_status` (`status`,`requested_at`);

-- --------------------------------------------------------

--
-- Structure de la vue `admin_v_kpi_daily`
--
DROP TABLE IF EXISTS `admin_v_kpi_daily`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `admin_v_kpi_daily`  AS SELECT cast(`b`.`placed_at` as date) AS `day`, count(0) AS `bets_count`, count(distinct `b`.`user_id`) AS `active_bettors`, coalesce(sum(`b`.`stake`),0) AS `stake_total`, coalesce(sum(`b`.`actual_payout`),0) AS `payouts_total`, (coalesce(sum(`b`.`stake`),0) - coalesce(sum(`b`.`actual_payout`),0)) AS `ggr_estimated`, sum((case when (`b`.`type` = 'SINGLE') then 1 else 0 end)) AS `singles_count`, sum((case when (`b`.`type` = 'ACCA') then 1 else 0 end)) AS `accas_count`, sum((case when (`b`.`status` = 'WON') then 1 else 0 end)) AS `won_count`, sum((case when (`b`.`status` = 'LOST') then 1 else 0 end)) AS `lost_count`, sum((case when (`b`.`status` = 'CASHED_OUT') then 1 else 0 end)) AS `cashout_count`, coalesce(sum((case when (`b`.`status` = 'CASHED_OUT') then `b`.`actual_payout` else 0 end)),0) AS `cashout_total`, avg(`b`.`total_odds`) AS `avg_odds` FROM `betting_bets` AS `b` WHERE (`b`.`placed_at` is not null) GROUP BY cast(`b`.`placed_at` as date) ORDER BY `day` ASC ;

-- --------------------------------------------------------

--
-- Structure de la vue `obs_v_fraud_pending`
--
DROP TABLE IF EXISTS `obs_v_fraud_pending`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `obs_v_fraud_pending`  AS SELECT `fs`.`id` AS `id`, `fs`.`user_id` AS `user_id`, `fs`.`session_id` AS `session_id`, `fs`.`signal_type` AS `signal_type`, `fs`.`severity` AS `severity`, `fs`.`score` AS `score`, `fs`.`description` AS `description`, `fs`.`evidence_json` AS `evidence_json`, `fs`.`status` AS `status`, `fs`.`reviewed_by` AS `reviewed_by`, `fs`.`review_notes` AS `review_notes`, `fs`.`action_taken` AS `action_taken`, `fs`.`detected_at` AS `detected_at`, `fs`.`reviewed_at` AS `reviewed_at`, `u`.`phone` AS `phone`, `u`.`email` AS `email`, `u`.`created_at` AS `user_created_at`, `w`.`balance_available` AS `balance_available` FROM ((`obs_fraud_signals` `fs` join `auth_users` `u` on((`u`.`id` = `fs`.`user_id`))) left join `wallet_wallets` `w` on((`w`.`user_id` = `fs`.`user_id`))) WHERE (`fs`.`status` in ('NEW','REVIEWING')) ORDER BY field(`fs`.`severity`,'CRITICAL','HIGH','MEDIUM','LOW') ASC, `fs`.`detected_at` DESC ;

-- --------------------------------------------------------

--
-- Structure de la vue `obs_v_funnel_daily`
--
DROP TABLE IF EXISTS `obs_v_funnel_daily`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `obs_v_funnel_daily`  AS SELECT cast(`obs_bet_funnel`.`created_at` as date) AS `day`, `obs_bet_funnel`.`step` AS `step`, `obs_bet_funnel`.`step_order` AS `step_order`, count(0) AS `step_count`, count(distinct `obs_bet_funnel`.`user_id`) AS `unique_users`, count(distinct `obs_bet_funnel`.`funnel_session_id`) AS `unique_funnels` FROM `obs_bet_funnel` GROUP BY cast(`obs_bet_funnel`.`created_at` as date), `obs_bet_funnel`.`step`, `obs_bet_funnel`.`step_order` ORDER BY `day` DESC, `obs_bet_funnel`.`step_order` ASC ;

-- --------------------------------------------------------

--
-- Structure de la vue `obs_v_odds_clicks_by_sport`
--
DROP TABLE IF EXISTS `obs_v_odds_clicks_by_sport`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `obs_v_odds_clicks_by_sport`  AS SELECT cast(`ct`.`clicked_at` as date) AS `day`, `s`.`name` AS `sport_name`, count(0) AS `odds_clicks`, count(distinct `ct`.`user_id`) AS `unique_clickers`, count(distinct `ct`.`event_id`) AS `events_with_clicks` FROM (`obs_click_tracking` `ct` join `sportsbook_sports` `s` on((`s`.`id` = `ct`.`sport_id`))) WHERE (`ct`.`click_type` = 'ODDS_SELECTION') GROUP BY cast(`ct`.`clicked_at` as date), `s`.`name` ORDER BY `day` DESC, `odds_clicks` DESC ;

-- --------------------------------------------------------

--
-- Structure de la vue `obs_v_top_pages`
--
DROP TABLE IF EXISTS `obs_v_top_pages`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `obs_v_top_pages`  AS SELECT `obs_page_views`.`page_type` AS `page_type`, count(0) AS `views`, count(distinct `obs_page_views`.`user_id`) AS `unique_visitors`, avg(`obs_page_views`.`time_on_page_seconds`) AS `avg_time_seconds`, avg(`obs_page_views`.`load_time_ms`) AS `avg_load_time_ms`, avg(`obs_page_views`.`scroll_depth_pct`) AS `avg_scroll_depth` FROM `obs_page_views` WHERE (`obs_page_views`.`viewed_at` >= (now() - interval 7 day)) GROUP BY `obs_page_views`.`page_type` ORDER BY `views` DESC ;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `admin_admin_actions`
--
ALTER TABLE `admin_admin_actions`
  ADD CONSTRAINT `fk_admin_actions_admin` FOREIGN KEY (`admin_user_id`) REFERENCES `admin_admin_users` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `admin_admin_users`
--
ALTER TABLE `admin_admin_users`
  ADD CONSTRAINT `fk_admin_role` FOREIGN KEY (`role_id`) REFERENCES `admin_roles` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `affiliate_affiliate_clicks`
--
ALTER TABLE `affiliate_affiliate_clicks`
  ADD CONSTRAINT `fk_aff_clicks_link` FOREIGN KEY (`affiliate_link_id`) REFERENCES `affiliate_affiliate_links` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `affiliate_affiliate_links`
--
ALTER TABLE `affiliate_affiliate_links`
  ADD CONSTRAINT `fk_aff_links_aff` FOREIGN KEY (`affiliate_id`) REFERENCES `affiliate_affiliates` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `affiliate_attributions`
--
ALTER TABLE `affiliate_attributions`
  ADD CONSTRAINT `fk_attrib_aff` FOREIGN KEY (`affiliate_id`) REFERENCES `affiliate_affiliates` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `fk_attrib_click` FOREIGN KEY (`click_id`) REFERENCES `affiliate_affiliate_clicks` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_attrib_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `affiliate_commissions`
--
ALTER TABLE `affiliate_commissions`
  ADD CONSTRAINT `fk_comm_aff` FOREIGN KEY (`affiliate_id`) REFERENCES `affiliate_affiliates` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `affiliate_conversions`
--
ALTER TABLE `affiliate_conversions`
  ADD CONSTRAINT `fk_conv_aff` FOREIGN KEY (`affiliate_id`) REFERENCES `affiliate_affiliates` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `fk_conv_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `affiliate_payouts`
--
ALTER TABLE `affiliate_payouts`
  ADD CONSTRAINT `fk_payout_aff` FOREIGN KEY (`affiliate_id`) REFERENCES `affiliate_affiliates` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `auth_kyc_profiles`
--
ALTER TABLE `auth_kyc_profiles`
  ADD CONSTRAINT `fk_kyc_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `auth_otp_codes`
--
ALTER TABLE `auth_otp_codes`
  ADD CONSTRAINT `fk_otp_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `auth_responsible_gaming`
--
ALTER TABLE `auth_responsible_gaming`
  ADD CONSTRAINT `fk_rg_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `auth_sessions`
--
ALTER TABLE `auth_sessions`
  ADD CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `betting_bets`
--
ALTER TABLE `betting_bets`
  ADD CONSTRAINT `fk_bets_betslip` FOREIGN KEY (`betslip_id`) REFERENCES `betting_betslips` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bets_bonus` FOREIGN KEY (`bonus_id`) REFERENCES `promo_bonuses` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bets_promo_redemption` FOREIGN KEY (`promo_redemption_id`) REFERENCES `promo_promo_redemptions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_bets_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `betting_betslips`
--
ALTER TABLE `betting_betslips`
  ADD CONSTRAINT `fk_betslips_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `betting_bet_legs`
--
ALTER TABLE `betting_bet_legs`
  ADD CONSTRAINT `fk_legs_bet` FOREIGN KEY (`bet_id`) REFERENCES `betting_bets` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_legs_event` FOREIGN KEY (`event_id`) REFERENCES `sportsbook_events` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `fk_legs_market` FOREIGN KEY (`market_id`) REFERENCES `sportsbook_markets` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `fk_legs_selection` FOREIGN KEY (`selection_id`) REFERENCES `sportsbook_selections` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `betting_cashout_offers`
--
ALTER TABLE `betting_cashout_offers`
  ADD CONSTRAINT `fk_cashout_offer_bet` FOREIGN KEY (`bet_id`) REFERENCES `betting_bets` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `betting_cashout_transactions`
--
ALTER TABLE `betting_cashout_transactions`
  ADD CONSTRAINT `fk_cashout_tx_bet` FOREIGN KEY (`bet_id`) REFERENCES `betting_bets` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `fk_cashout_tx_offer` FOREIGN KEY (`offer_id`) REFERENCES `betting_cashout_offers` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `fk_cashout_tx_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `betting_settlement_jobs`
--
ALTER TABLE `betting_settlement_jobs`
  ADD CONSTRAINT `fk_jobs_event` FOREIGN KEY (`event_id`) REFERENCES `sportsbook_events` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `br_feed_messages`
--
ALTER TABLE `br_feed_messages`
  ADD CONSTRAINT `fk_brfm_event` FOREIGN KEY (`event_id`) REFERENCES `sportsbook_events` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_brfm_producer` FOREIGN KEY (`producer_id`) REFERENCES `br_producers` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `br_market_mapping`
--
ALTER TABLE `br_market_mapping`
  ADD CONSTRAINT `fk_brmm_sport` FOREIGN KEY (`sport_id`) REFERENCES `sportsbook_sports` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_brmm_type` FOREIGN KEY (`market_type_id`) REFERENCES `sportsbook_market_types` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `notif_notifications`
--
ALTER TABLE `notif_notifications`
  ADD CONSTRAINT `fk_notif_template` FOREIGN KEY (`template_id`) REFERENCES `notif_templates` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `notif_preferences`
--
ALTER TABLE `notif_preferences`
  ADD CONSTRAINT `fk_notif_pref_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `obs_bet_funnel`
--
ALTER TABLE `obs_bet_funnel`
  ADD CONSTRAINT `fk_bf_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `obs_click_tracking`
--
ALTER TABLE `obs_click_tracking`
  ADD CONSTRAINT `fk_ct_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `obs_device_fingerprints`
--
ALTER TABLE `obs_device_fingerprints`
  ADD CONSTRAINT `fk_df_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `obs_error_logs`
--
ALTER TABLE `obs_error_logs`
  ADD CONSTRAINT `fk_err_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `obs_fraud_signals`
--
ALTER TABLE `obs_fraud_signals`
  ADD CONSTRAINT `fk_fs_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `admin_admin_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_fs_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `obs_login_attempts`
--
ALTER TABLE `obs_login_attempts`
  ADD CONSTRAINT `fk_la_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `obs_page_views`
--
ALTER TABLE `obs_page_views`
  ADD CONSTRAINT `fk_pv_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `obs_search_logs`
--
ALTER TABLE `obs_search_logs`
  ADD CONSTRAINT `fk_sl_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `obs_sessions_tracking`
--
ALTER TABLE `obs_sessions_tracking`
  ADD CONSTRAINT `fk_ost_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `obs_user_events`
--
ALTER TABLE `obs_user_events`
  ADD CONSTRAINT `fk_obs_events_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `promo_bonuses`
--
ALTER TABLE `promo_bonuses`
  ADD CONSTRAINT `fk_bonus_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `promo_promo_redemptions`
--
ALTER TABLE `promo_promo_redemptions`
  ADD CONSTRAINT `fk_redemptions_code` FOREIGN KEY (`promo_code_id`) REFERENCES `promo_promo_codes` (`id`) ON DELETE RESTRICT,
  ADD CONSTRAINT `fk_redemptions_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `promo_wagering_events`
--
ALTER TABLE `promo_wagering_events`
  ADD CONSTRAINT `fk_wager_bet` FOREIGN KEY (`bet_id`) REFERENCES `betting_bets` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_wager_bonus` FOREIGN KEY (`bonus_id`) REFERENCES `promo_bonuses` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `sportsbook_events`
--
ALTER TABLE `sportsbook_events`
  ADD CONSTRAINT `fk_events_away` FOREIGN KEY (`away_team_id`) REFERENCES `sportsbook_teams` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_events_home` FOREIGN KEY (`home_team_id`) REFERENCES `sportsbook_teams` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_events_league` FOREIGN KEY (`league_id`) REFERENCES `sportsbook_leagues` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_events_sport` FOREIGN KEY (`sport_id`) REFERENCES `sportsbook_sports` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `sportsbook_event_participants`
--
ALTER TABLE `sportsbook_event_participants`
  ADD CONSTRAINT `fk_ep_event` FOREIGN KEY (`event_id`) REFERENCES `sportsbook_events` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_ep_team` FOREIGN KEY (`team_id`) REFERENCES `sportsbook_teams` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `sportsbook_leagues`
--
ALTER TABLE `sportsbook_leagues`
  ADD CONSTRAINT `fk_leagues_country` FOREIGN KEY (`country_id`) REFERENCES `sportsbook_countries` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_leagues_sport` FOREIGN KEY (`sport_id`) REFERENCES `sportsbook_sports` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `sportsbook_markets`
--
ALTER TABLE `sportsbook_markets`
  ADD CONSTRAINT `fk_markets_event` FOREIGN KEY (`event_id`) REFERENCES `sportsbook_events` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_markets_type` FOREIGN KEY (`market_type_id`) REFERENCES `sportsbook_market_types` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `sportsbook_market_types`
--
ALTER TABLE `sportsbook_market_types`
  ADD CONSTRAINT `fk_mt_sport` FOREIGN KEY (`sport_id`) REFERENCES `sportsbook_sports` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `sportsbook_odds_snapshots`
--
ALTER TABLE `sportsbook_odds_snapshots`
  ADD CONSTRAINT `fk_odds_selection` FOREIGN KEY (`selection_id`) REFERENCES `sportsbook_selections` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `sportsbook_selections`
--
ALTER TABLE `sportsbook_selections`
  ADD CONSTRAINT `fk_selections_market` FOREIGN KEY (`market_id`) REFERENCES `sportsbook_markets` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `sportsbook_teams`
--
ALTER TABLE `sportsbook_teams`
  ADD CONSTRAINT `fk_teams_country` FOREIGN KEY (`country_id`) REFERENCES `sportsbook_countries` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_teams_sport` FOREIGN KEY (`sport_id`) REFERENCES `sportsbook_sports` (`id`) ON DELETE RESTRICT;

--
-- Contraintes pour la table `wallet_idempotency_keys`
--
ALTER TABLE `wallet_idempotency_keys`
  ADD CONSTRAINT `fk_idem_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `wallet_ledger_entries`
--
ALTER TABLE `wallet_ledger_entries`
  ADD CONSTRAINT `fk_ledger_wallet` FOREIGN KEY (`wallet_id`) REFERENCES `wallet_wallets` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `wallet_payments`
--
ALTER TABLE `wallet_payments`
  ADD CONSTRAINT `fk_payments_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `wallet_wallets`
--
ALTER TABLE `wallet_wallets`
  ADD CONSTRAINT `fk_wallet_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;

--
-- Contraintes pour la table `wallet_withdrawals`
--
ALTER TABLE `wallet_withdrawals`
  ADD CONSTRAINT `fk_withdrawals_user` FOREIGN KEY (`user_id`) REFERENCES `auth_users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
