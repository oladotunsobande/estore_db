-- -----------------------------------------------------
-- procedure rtn_prd_det
-- -----------------------------------------------------

DROP procedure IF EXISTS `jemimah`.`rtn_prd_det`;

DELIMITER $$
CREATE DEFINER=`jmm_sys`@`%` PROCEDURE `rtn_prd_det`(in prd_rk int, out pr_dt json, out er_msg varchar(500))
begin
    declare prd_id integer;
    declare prd_ctg_id integer;
    declare ctg_nme varchar(100);
    declare prd_nm varchar(300);
    declare prd_det varchar(10000);
    declare prd_ttl integer;
    declare unt_prc decimal(15,2);
    declare old_prc decimal(15,2);
    declare dst_val decimal(6,2);
    declare dst_amt decimal(15,2);
    declare ext_dtls json;
    declare qty_sld integer;
    declare prd_img json;
    declare prd_sta varchar(20);
    declare upd_dt varchar(40);
    declare prd_obj json;
	declare exit handler for sqlexception
	begin
		get diagnostics condition 1 @errno = mysql_errno, @text = message_text;
		set @err_msg = concat("ERR-", @errno, " : ", @text);
		select @err_msg into er_msg;
	end;

    if prd_rk = null or prd_rk = '' then
        set er_msg = 'Argument is null';
    else
        select 
        id, ctg_id, ctg_nm, prd_nme, prd_dtls, prd_cnt, cur_unt_prc, old_unt_prc, dst_per, dsct_amt, oth_det, sale_cnt, prd_pix, prd_stat, upd_dte
        into
        prd_id, prd_ctg_id, ctg_nme, prd_nm, prd_det, prd_ttl, unt_prc, old_prc, dst_val, dst_amt, ext_dtls, qty_sld, prd_img, prd_sta, upd_dt
        from vw_prd_lst
        where id = prd_rk;

        set prd_obj = json_object(
                        'prd_id', bnr_id,
                        'ctg_id', prd_ctg_id,
                        'ctg_nme', ctg_nme,
                        'prd_nme', prd_nm,
                        'prd_dtls', prd_det,
                        'prd_qty', prd_ttl,
                        'cur_unt_prc', unt_prc,
                        'old_unt_prc', old_prc,
                        'dsc_per_val', dst_val,
                        'dsc_amt', dst_amt,
                        'oth_dtls', ext_dtls,
                        'sle_qty', qty_sld,
                        'prd_imgs', prd_img,
                        'prd_stt', prd_sta,
                        'upd_dte', upd_dt
                    );

        set pr_dt = prd_obj;
    end if;
end$$
DELIMITER ;

-- -----------------------------------------------------
-- procedure rtn_prd_ctg
-- -----------------------------------------------------

DROP procedure IF EXISTS `jemimah`.`rtn_prd_ctg`;

DELIMITER $$
CREATE DEFINER=`jmm_sys`@`%` PROCEDURE `rtn_prd_ctg`(out pr_dt json, out er_msg varchar(500))
begin
    declare ctg_id integer;
    declare ctg_nme varchar(100);
    declare crtv_url varchar(500);
    declare crtv_lst json;
    declare upd_dte varchar(50);
    declare ctg_obj json;
    declare ctg_arr json default json_array();
    declare done integer default 0;
    declare cursor csr_ctg_lst for
        select * from vw_prd_ctg; 
    declare continue handler for not found set done = 1;
	declare exit handler for sqlexception
	begin
		get diagnostics condition 1 @errno = mysql_errno, @text = message_text;
		set @err_msg = concat("ERR-", @errno, " : ", @text);
		select @err_msg into er_msg;
	end;

    open csr_ctg_lst;

    loop1: loop
        fetch csr_ctg_lst into ctg_id, ctg_nme, crtv_url, crtv_lst, upd_dte;

        if done = 1 then
            leave loop1;
        end if;

        set ctg_obj = json_object(
                        'ctg_id', ctg_id,
                        'ctg_nme', ctg_nme,
                        'crtv_url', crtv_url,
                        'crtv_lst', crtv_lst,
                        'upd_dte', upd_dte
                    );
        set ctg_arr = json_array_append(ctg_arr, '$', bnr_obj);
    end loop loop1;

    close csr_ctg_lst;

    set pr_dt = ctg_arr;
end$$
DELIMITER ;


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

    loop1: loop
        fetch csr_bnr_lst into bnr_id, bnr_src, bnr_sta;

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
    declare prd_ttl integer;
    declare unt_prc decimal(15,2);
    declare old_prc decimal(15,2);
    declare dst_val decimal(6,2);
    declare dst_amt decimal(15,2);
    declare ext_dtls json;
    declare qty_sld integer;
    declare prd_img json;
    declare prd_sta varchar(20);
    declare upd_dt varchar(40);
    declare prd_obj json;
    declare prd_arr json default json_array();
    declare done integer default 0;
    declare cursor csr_ctg_prd_lst for
        select * from vw_prd_lst where ctg_id = ety_id;
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

    if (act_typ = null or act_typ = '') and (ety_id = null or ety_id = '') then
        set er_msg = 'Arguments are null';
    else
        case act_typ
            when 'category_products' then
                open csr_ctg_prd_lst;

                loop1: loop
                    fetch csr_ctg_prd_lst into
                    prd_id, prd_ctg_id, ctg_nme, prd_nm, prd_det, prd_ttl, unt_prc, old_prc, dst_val, dst_amt, ext_dtls, qty_sld, prd_img, prd_sta, upd_dt;

                    if done = 1 then
                        leave loop1;
                    end if;

                    set prd_obj = json_object(
                                    'prd_id', bnr_id,
                                    'ctg_id', prd_ctg_id,
                                    'ctg_nme', ctg_nme,
                                    'prd_nme', prd_nm,
                                    'prd_dtls', prd_det,
                                    'prd_qty', prd_ttl,
                                    'cur_unt_prc', unt_prc,
                                    'old_unt_prc', old_prc,
                                    'dsc_per_val', dst_val,
                                    'dsc_amt', dst_amt,
                                    'oth_dtls', ext_dtls,
                                    'sle_qty', qty_sld,
                                    'prd_imgs', prd_img,
                                    'prd_stt', prd_sta,
                                    'upd_dte', upd_dt
                                );
                    set prd_arr = json_array_append(prd_arr, '$', prd_obj);
                end loop loop1;

                close csr_ctg_prd_lst;
            when 'products_list' then
                open csr_prd_lst;

                loop1: loop
                    fetch csr_prd_lst into
                    prd_id, prd_ctg_id, ctg_nme, prd_nm, prd_det, prd_ttl, unt_prc, old_prc, dst_val, dst_amt, ext_dtls, qty_sld, prd_img, prd_sta, upd_dt;

                    if done = 1 then
                        leave loop1;
                    end if;

                    set prd_obj = json_object(
                                    'prd_id', bnr_id,
                                    'ctg_id', prd_ctg_id,
                                    'ctg_nme', ctg_nme,
                                    'prd_nme', prd_nm,
                                    'prd_dtls', prd_det,
                                    'prd_qty', prd_ttl,
                                    'cur_unt_prc', unt_prc,
                                    'old_unt_prc', old_prc,
                                    'dsc_per_val', dst_val,
                                    'dsc_amt', dst_amt,
                                    'oth_dtls', ext_dtls,
                                    'sle_qty', qty_sld,
                                    'prd_imgs', prd_img,
                                    'prd_stt', prd_sta,
                                    'upd_dte', upd_dt
                                );
                    set prd_arr = json_array_append(prd_arr, '$', prd_obj);
                end loop loop1;

                close csr_prd_lst;
            when 'sales_count' then
                open csr_prd_tp_sle;

                loop1: loop
                    fetch csr_prd_tp_sle into
                    prd_id, prd_ctg_id, ctg_nme, prd_nm, prd_det, prd_ttl, unt_prc, old_prc, dst_val, dst_amt, ext_dtls, qty_sld, prd_img, prd_sta, upd_dt;

                    if done = 1 then
                        leave loop1;
                    end if;

                    set prd_obj = json_object(
                                    'prd_id', bnr_id,
                                    'ctg_id', prd_ctg_id,
                                    'ctg_nme', ctg_nme,
                                    'prd_nme', prd_nm,
                                    'prd_dtls', prd_det,
                                    'prd_qty', prd_ttl,
                                    'cur_unt_prc', unt_prc,
                                    'old_unt_prc', old_prc,
                                    'dsc_per_val', dst_val,
                                    'dsc_amt', dst_amt,
                                    'oth_dtls', ext_dtls,
                                    'sle_qty', qty_sld,
                                    'prd_imgs', prd_img,
                                    'prd_stt', prd_sta,
                                    'upd_dte', upd_dt
                                );
                    set prd_arr = json_array_append(prd_arr, '$', prd_obj);
                end loop loop1;

                close csr_prd_tp_sle;
        end case;

        set pr_dt = prd_arr;
    end if;
end$$

DELIMITER ;