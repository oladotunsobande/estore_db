-- -----------------------------------------------------
-- procedure rtn_prm_bnrs
-- -----------------------------------------------------

DROP procedure IF EXISTS `jemimah`.`rtn_prm_bnrs`;

DELIMITER $$
CREATE DEFINER=`jmm_sys`@`%` PROCEDURE `rtn_prm_bnrs`(out pr_dt json, out er_msg varchar(500))
begin
    declare bnr_id integer;
    declare bnr_src varchar(500);
    declare bnr_sta varchar(20);
    declare bnr_obj json;
    declare bnr_arr json default json_array();
    declare done integer default 0;
    declare cursor csr_bnr_lst for
        select id, bnr_lnk from vw_prm_bnr; 
    declare continue handler for not found set done = 1;
	declare exit handler for sqlexception
	begin
		get diagnostics condition 1 @errno = mysql_errno, @text = message_text;
		set @err_msg = concat("ERR-", @errno, " : ", @text);
		select @err_msg into er_msg;
	end;

    open csr_bnr_lst;

    loop1: loop1
        fetch id, bnr_lnk, bnr_stat into bnr_id, bnr_src, bnr_sta;

        if done = 1 then
            leave loop1;
        end if;

        set bnr_obj = json_object(
                        'bnr_id', bnr_id,
                        'bnr_src', bnr_src,
                        'bnr_stt', bnr_sta
                    );
        set bnr_arr = json_array_append(bnr_arr, '$', bnr_obj);
    end loop loop1;

    close csr_bnr_lst;

    set pr_dt = bnr_arr;
end$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure rtn_prd_lst
-- -----------------------------------------------------

DROP procedure IF EXISTS `jemimah`.`rtn_prd_lst`;

DELIMITER $$
CREATE DEFINER=`jmm_sys`@`%` PROCEDURE `rtn_prd_lst`(in act_typ varchar(100), in ety_id int, out pr_dt json, out er_msg varchar(500))
begin
    declare prd_id integer;
    declare prd_ctg_id integer;
    declare ctg_nme varchar(100);
    declare prd_nm varchar(300);
    declare prd_det varchar(10000);
    declare prd_cnt integer;
    declare unt_prc decimal(15,2);
    declare old_prc decimal(15,2);
    declare dst_val decimal(6,2);
    declare dst_amt decimal(15,2);
    declare ext_dtls json;
    declare qty_sld integer;
    declare prd_img json;
    declare prd_sta varchar(20);
    declare upd_dte varchar(40);
    declare prd_obj json;
    declare prd_arr json default json_array();
    declare done integer default 0;
    declare cursor csr_prd_lst for
        select * from vw_prd_lst;
    declare cursor csr_prd_tp_sle for
        select * from vw_prd_lst order by sale_cnt desc; 
    declare continue handler for not found set done = 1;
	declare exit handler for sqlexception
	begin
		get diagnostics condition 1 @errno = mysql_errno, @text = message_text;
		set @err_msg = concat("ERR-", @errno, " : ", @text);
		select @err_msg into er_msg;
	end;

    open csr_bnr_lst;

    loop1: loop1
        fetch id, bnr_lnk, bnr_stat into bnr_id, bnr_src, bnr_sta;

        if done = 1 then
            leave loop1;
        end if;

        set bnr_obj = json_object(
                        'bnr_id', bnr_id,
                        'bnr_src', bnr_src,
                        'bnr_stt', bnr_sta
                    );
        set bnr_arr = json_array_append(bnr_arr, '$', bnr_obj);
    end loop loop1;

    close csr_bnr_lst;

    set pr_dt = prd_arr;
end$$

DELIMITER ;