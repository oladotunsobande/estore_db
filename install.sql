-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema jemimah
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema jemimah
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `jemimah` DEFAULT CHARACTER SET utf8 ;
USE `jemimah` ;

-- -----------------------------------------------------
-- Table `jemimah`.`sys_prm`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`sys_prm` (
  `r_k` INT NOT NULL AUTO_INCREMENT,
  `prm_dsc` VARCHAR(100) NOT NULL,
  `prm_obj` JSON NOT NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`adm_usr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`adm_usr` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `fst_nme` VARCHAR(100) NOT NULL,
  `lst_nme` VARCHAR(150) NOT NULL,
  `usr_gdr` ENUM('MALE', 'FEMALE') NOT NULL,
  `usr_eml` VARCHAR(500) NOT NULL,
  `pic_url` VARCHAR(800) NULL,
  `prv_lvl` ENUM('ADMIN', 'USER') NOT NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`tsk_lst`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`tsk_lst` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `adm_usr_r_k` INT UNSIGNED NOT NULL,
  `tsk_dsc` VARCHAR(200) NOT NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_tsk_lst_adm_usr1_idx` (`adm_usr_r_k` ASC),
  CONSTRAINT `fk_tsk_lst_adm_usr1`
    FOREIGN KEY (`adm_usr_r_k`)
    REFERENCES `jemimah`.`adm_usr` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`adm_usr_ath`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`adm_usr_ath` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `adm_usr_r_k` INT UNSIGNED NOT NULL,
  `ath_hsh` VARCHAR(900) NOT NULL,
  `ath_slt` VARCHAR(900) NOT NULL,
  `sec_qtn` VARCHAR(300) NOT NULL,
  `sec_ans` VARCHAR(200) NOT NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_adm_usr_ath_adm_usr_idx` (`adm_usr_r_k` ASC),
  CONSTRAINT `fk_adm_usr_ath_adm_usr`
    FOREIGN KEY (`adm_usr_r_k`)
    REFERENCES `jemimah`.`adm_usr` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`cust_mstr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`cust_mstr` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `fst_nme` VARCHAR(100) NOT NULL,
  `lst_nme` VARCHAR(300) NOT NULL,
  `usr_eml` VARCHAR(1000) NOT NULL,
  `phn_num` VARCHAR(45) NOT NULL,
  `usr_gdr` ENUM('MALE', 'FEMALE') NOT NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`cust_ath`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`cust_ath` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cust_mstr_r_k` INT UNSIGNED NOT NULL,
  `ath_hsh` VARCHAR(1000) NOT NULL,
  `ath_slt` VARCHAR(700) NOT NULL,
  `sec_qtn` VARCHAR(500) NOT NULL,
  `sec_ans` VARCHAR(500) NOT NULL,
  `acct_stt` ENUM('ACTIVE', 'INACITVE') NOT NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_cust_ath_cust_mstr1_idx` (`cust_mstr_r_k` ASC),
  CONSTRAINT `fk_cust_ath_cust_mstr1`
    FOREIGN KEY (`cust_mstr_r_k`)
    REFERENCES `jemimah`.`cust_mstr` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`ste_lst`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`ste_lst` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ste_nme` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`lga_lst`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`lga_lst` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ste_lst_r_k` INT UNSIGNED NOT NULL,
  `lga_nme` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_lga_lst_ste_lst1_idx` (`ste_lst_r_k` ASC),
  CONSTRAINT `fk_lga_lst_ste_lst1`
    FOREIGN KEY (`ste_lst_r_k`)
    REFERENCES `jemimah`.`ste_lst` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`shp_dtls`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`shp_dtls` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cust_mstr_r_k` INT UNSIGNED NOT NULL,
  `res_addr` VARCHAR(1000) NOT NULL,
  `lga_lst_r_k` INT UNSIGNED NOT NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_shp_dtls_cust_mstr1_idx` (`cust_mstr_r_k` ASC),
  INDEX `fk_shp_dtls_lga_lst1_idx` (`lga_lst_r_k` ASC),
  CONSTRAINT `fk_shp_dtls_cust_mstr1`
    FOREIGN KEY (`cust_mstr_r_k`)
    REFERENCES `jemimah`.`cust_mstr` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_shp_dtls_lga_lst1`
    FOREIGN KEY (`lga_lst_r_k`)
    REFERENCES `jemimah`.`lga_lst` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`cust_ord`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`cust_ord` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cust_mstr_r_k` INT UNSIGNED NOT NULL,
  `ord_num` VARCHAR(45) NOT NULL,
  `ord_amt` DECIMAL(15,2) NOT NULL,
  `dvry_fee` DECIMAL(15,2) NOT NULL,
  `ord_stt` ENUM('PENDING', 'CONFIRMED', 'DELIVERED', 'CANCELLED') NOT NULL,
  `ord_dte` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_cust_ord_cust_mstr1_idx` (`cust_mstr_r_k` ASC),
  CONSTRAINT `fk_cust_ord_cust_mstr1`
    FOREIGN KEY (`cust_mstr_r_k`)
    REFERENCES `jemimah`.`cust_mstr` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`ord_pymt`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`ord_pymt` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cust_ord_r_k` INT UNSIGNED NOT NULL,
  `pymt_mtd` ENUM('CASH ON DELIVERY', 'INTERNET PAY') NOT NULL,
  `pymt_stt` ENUM('PENDING', 'COMPLETE') NOT NULL,
  `trn_dte` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`, `cust_ord_r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_ord_pymt_cust_ord1_idx` (`cust_ord_r_k` ASC),
  CONSTRAINT `fk_ord_pymt_cust_ord1`
    FOREIGN KEY (`cust_ord_r_k`)
    REFERENCES `jemimah`.`cust_ord` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`prm_bnr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`prm_bnr` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `bnr_dsc` VARCHAR(200) NOT NULL,
  `bnr_url` VARCHAR(500) NOT NULL,
  `bnr_stt` ENUM('ACTIVE','INACTIVE') NOT NULL,
  `crtn_dte` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`prd_ctg`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`prd_ctg` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ctg_nme` VARCHAR(100) NOT NULL,
  `ctg_crtv_url` VARCHAR(500) NULL,
  `crtv_url_lst` JSON NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`prd_lst`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`prd_lst` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `prd_ctg_r_k` INT UNSIGNED NOT NULL,
  `prd_nme` VARCHAR(300) NOT NULL,
  `prd_dsc` MEDIUMTEXT NOT NULL,
  `prd_qty` INT NOT NULL,
  `curr_prc` DECIMAL(15,2) NOT NULL,
  `fmr_prc` DECIMAL(15,2) NULL,
  `dsct_val` DECIMAL(6,2) NULL,
  `oth_dtls` JSON NULL,
  `sal_cnt` INT NOT NULL DEFAULT 0,
  `pic_url` JSON NOT NULL,
  `prd_stt` ENUM('ACTIVE', 'INACTIVE') NOT NULL,
  `lst_upd` DATETIME NOT NULL,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_prd_lst_prd_ctg1_idx` (`prd_ctg_r_k` ASC),
  CONSTRAINT `fk_prd_lst_prd_ctg1`
    FOREIGN KEY (`prd_ctg_r_k`)
    REFERENCES `jemimah`.`prd_ctg` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`dsp_rdr`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`dsp_rdr` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `fst_nme` VARCHAR(100) NOT NULL,
  `lst_nme` VARCHAR(100) NOT NULL,
  `phn_num` VARCHAR(45) NOT NULL,
  `vhc_typ` ENUM('TRUCK', 'VAN', 'MOTOR BIKE', 'CAR') NOT NULL,
  `vhc_dsc` JSON NULL,
  `pic_url` VARCHAR(1000) NULL,
  `rdr_stt` ENUM('ACTIVE', 'INACTIVE') NOT NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`ord_dvry`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`ord_dvry` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cust_ord_r_k` INT UNSIGNED NOT NULL,
  `dsp_rdr_r_k` INT UNSIGNED NOT NULL,
  `dvry_stt` ENUM('PENDING', 'IN PROGRESS', 'COMPLETED') NOT NULL,
  `lst_upd` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_ord_dvry_cust_ord1_idx` (`cust_ord_r_k` ASC),
  INDEX `fk_ord_dvry_dsp_rdr1_idx` (`dsp_rdr_r_k` ASC),
  CONSTRAINT `fk_ord_dvry_cust_ord1`
    FOREIGN KEY (`cust_ord_r_k`)
    REFERENCES `jemimah`.`cust_ord` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_ord_dvry_dsp_rdr1`
    FOREIGN KEY (`dsp_rdr_r_k`)
    REFERENCES `jemimah`.`dsp_rdr` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`cust_ord_prd_lst`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`cust_ord_prd_lst` (
  `cust_ord_r_k` INT UNSIGNED NOT NULL,
  `prd_lst_r_k` INT UNSIGNED NOT NULL,
  `ord_qty` INT NOT NULL,
  PRIMARY KEY (`cust_ord_r_k`, `prd_lst_r_k`),
  INDEX `fk_cust_ord_has_prd_lst_prd_lst1_idx` (`prd_lst_r_k` ASC),
  INDEX `fk_cust_ord_has_prd_lst_cust_ord1_idx` (`cust_ord_r_k` ASC),
  CONSTRAINT `fk_cust_ord_has_prd_lst_cust_ord1`
    FOREIGN KEY (`cust_ord_r_k`)
    REFERENCES `jemimah`.`cust_ord` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_cust_ord_has_prd_lst_prd_lst1`
    FOREIGN KEY (`prd_lst_r_k`)
    REFERENCES `jemimah`.`prd_lst` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`rtn_prd`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`rtn_prd` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cust_ord_r_k` INT UNSIGNED NOT NULL,
  `rtn_rsn` VARCHAR(1000) NOT NULL,
  `rtn_dte` DATETIME NOT NULL,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_rtn_prd_cust_ord1_idx` (`cust_ord_r_k` ASC),
  CONSTRAINT `fk_rtn_prd_cust_ord1`
    FOREIGN KEY (`cust_ord_r_k`)
    REFERENCES `jemimah`.`cust_ord` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `jemimah`.`cust_fbk`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `jemimah`.`cust_fbk` (
  `r_k` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cust_mstr_r_k` INT UNSIGNED NOT NULL,
  `fbk_sub` VARCHAR(200) NULL,
  `fbk_dtls` LONGTEXT NOT NULL,
  `fbk_dte` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`r_k`),
  UNIQUE INDEX `r_k_UNIQUE` (`r_k` ASC),
  INDEX `fk_cust_fbk_cust_mstr1_idx` (`cust_mstr_r_k` ASC),
  CONSTRAINT `fk_cust_fbk_cust_mstr1`
    FOREIGN KEY (`cust_mstr_r_k`)
    REFERENCES `jemimah`.`cust_mstr` (`r_k`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- VIEWS
-- -----------------------------------------------------

-- -----------------------------------------------------
-- View `jemimah`.`vw_prd_lst`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `bdc`.`vw_prd_lst`;
DROP TABLE IF EXISTS `bdc`.`vw_prd_lst`;
USE `bdc`;
CREATE OR REPLACE VIEW `vw_prd_lst`
AS
SELECT
    pl.r_k id,
    pl.prd_ctg_r_k ctg_id,
    (select ctg_nme from prd_ctg where r_k = pl.prd_ctg_r_k) ctg_nm,
    pl.prd_nme prd_nme,
    pl.prd_dsc prd_dtls,
    pl.prd_qty prd_cnt,
    pl.curr_prc cur_unt_prc,
    pl.fmr_prc old_unt_prc,
    pl.dsct_val dst_per,
    (pl.dsct_val / 100) * pl.curr_prc dsct_amt,
    pl.oth_dtls oth_det,
    pl.sal_cnt sale_cnt,
    pl.pic_url prd_pix,
    pl.prd_stt prd_stat,
    pl.lst_upd upd_dte
FROM prd_lst pl;


-- -----------------------------------------------------
-- View `jemimah`.`vw_prm_bnr`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `bdc`.`vw_prm_bnr`;
DROP TABLE IF EXISTS `bdc`.`vw_prm_bnr`;
USE `bdc`;
CREATE OR REPLACE VIEW `vw_prm_bnr`
AS
SELECT
    pb.r_k id,
    pb.bnr_url bnr_lnk,
    pb.bnr_stt bnr_stat,
    pb.crtn_dte lst_upd
FROM prm_bnr pb;


-- -----------------------------------------------------
-- View `jemimah`.`vw_prd_ctg`
-- -----------------------------------------------------
DROP VIEW IF EXISTS `bdc`.`vw_prd_ctg`;
DROP TABLE IF EXISTS `bdc`.`vw_prd_ctg`;
USE `bdc`;
CREATE OR REPLACE VIEW `vw_prd_ctg`
AS
SELECT
    pc.r_k id,
    pc.ctg_nme ctg_nm,
    pc.ctg_crtv_url sng_crtv_url,
    pc.crtv_url_lst crtv_bnr_lst,
    pc.lst_upd upd_dte
FROM prd_ctg pc;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
