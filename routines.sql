-- -----------------------------------------------------
-- procedure rtn_cus_dtls
-- -----------------------------------------------------

DROP procedure IF EXISTS `jemimah`.`rtn_cus_dtls`;

DELIMITER $$
CREATE DEFINER=`jmm_sys`@`%` PROCEDURE `rtn_cus_dtls`(in cus_id int, out pr_dt json, out er_msg varchar(500))
begin
    declare usr_id integer;
    declare fst_nam varchar(100);
    declare lst_nam varchar(300);
    declare cust_add varchar(1000);
    declare cust_eml varchar(1000);
    declare phn_nmb varchar(45);
    declare cust_gdr varchar(15);
    declare lga_nm varchar(100);
    declare sta_nm varchar(45);
    declare acc_stat varchar(15);
    declare bsc_obj json;
    declare add_obj json;
    declare rsp_obj json;
	declare exit handler for sqlexception
	begin
		get diagnostics condition 1 @errno = mysql_errno, @text = message_text;
		set @err_msg = concat("ERR-", @errno, " : ", @text);
		select @err_msg into er_msg;
	end;

    if cus_id is null or cus_id = '' then
        set er_msg = 'Argument is null';
    else
        select 
        id, fst_nm, lst_nm, cus_addr, lga_nme, sta_nme, cus_eml, phn_nm, cus_gdr, acc_stt
        into 
        usr_id, fst_nam, lst_nam, cust_add, lga_nm, sta_nm, cust_eml, phn_nmb, cust_gdr, acc_stat
        from vw_cus_dtls
        where id = cus_id;

        set bsc_obj = json_object(
                        'cust_id', usr_id,
                        'fst_nme', fst_nm,
                        'lst_nme', lst_nm,
                        'cust_eml', cust_eml,
                        'phn_num', phn_nmb,
                        'cust_gdr' cust_gdr
                    );
        set add_obj = json_object(
                        'res_add', cust_add,
                        'lga_nme', lga_nm,
                        'sta_nme', sta_nm
                    );

        set rsp_obj = json_object('basic', bsc_obj, 'address', add_obj);

        set pr_dt = rsp_obj;
    end if;
end$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure rtn_ath_dtls
-- -----------------------------------------------------

DROP procedure IF EXISTS `jemimah`.`rtn_ath_dtls`;

DELIMITER $$
CREATE DEFINER=`jmm_sys`@`%` PROCEDURE `rtn_ath_dtls`(in usr_typ varchar(50), in usr_eml varchar(500), out pr_dt json, out er_msg varchar(500))
begin
    declare usr_id integer;
    declare hsh_pwd varchar(1000);
    declare pwd_slt varchar(700);
    declare acc_stat varchar(15);
    declare rsp_obj json;
	declare exit handler for sqlexception
	begin
		get diagnostics condition 1 @errno = mysql_errno, @text = message_text;
		set @err_msg = concat("ERR-", @errno, " : ", @text);
		select @err_msg into er_msg;
	end;

    if (usr_typ is not null and usr_typ != '') and (usr_eml is not null and usr_eml != '') then
        case usr_typ
            when 'customer' then
                select pwd_hsh, hsh_slt, acc_stt into hsh_pwd, pwd_slt, acc_stat from vw_cus_dtls where cus_eml = usr_eml;
                if acc_stat = 'ACTIVE' then
                    set pr_dt = json_object('pwd_hsh', hsh_pwd, 'hsh_slt', pwd_slt);
                else
                    set pr_dt = json_object('message', 'User account is inactive');
                end if;
            when 'admin' then
                null;
        end case;
    else
        set er_msg = 'Arguments are null';
    end if;
end$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure rtn_ath_usr
-- -----------------------------------------------------

DROP procedure IF EXISTS `jemimah`.`rtn_ath_usr`;

DELIMITER $$
CREATE DEFINER=`jmm_sys`@`%` PROCEDURE `rtn_ath_usr`(in usr_typ varchar(50), in usr_id int, in ses_tkn varchar(1000), out pr_stt int, out er_msg varchar(500))
begin
    declare rw_cnt integer;
    declare acc_stat varchar(15);
    declare vch_stat varchar(10);
    declare dys_dff integer;
    declare rp_vl json;
    declare er_vl varchar(500);
	declare exit handler for sqlexception
	begin
		get diagnostics condition 1 @errno = mysql_errno, @text = message_text;
		set @err_msg = concat("ERR-", @errno, " : ", @text);
		select @err_msg into er_msg;
	end;

    if (usr_typ is not null and usr_typ != '') and (usr_id is not null and usr_id != '') and (ses_tkn is not null and ses_tkn != '') then
        case usr_typ
            when 'customer' then
                select count(*) into rw_cnt from vw_cus_dtls where id = usr_id and acc_stt = 'ACTIVE';

                if rw_cnt = 1 then
                    set rsp_arr = json_array_append(rsp_arr, '$', ses_tkn);

                    update cust_ath set ath_tkn = rsp_arr, lst_upd = now() where id = usr_id;
                    commit;

                    set pr_stt = 1;
                else
                    set pr_stt = 0;
                end if;
            when 'admin' then
                null;
        end case;
    else
        set er_msg = 'Arguments are null';
    end if;
end$$

DELIMITER ;


-- -----------------------------------------------------
-- procedure rtn_vch_vld
-- -----------------------------------------------------

DROP procedure IF EXISTS `jemimah`.`rtn_vch_vld`;

DELIMITER $$
CREATE DEFINER=`jmm_sys`@`%` PROCEDURE `rtn_vch_vld`(in ref_num varchar(100), out pr_dt json, out er_msg varchar(500))
begin
    declare iss_dt varchar(30);
    declare vch_tnr integer;
    declare vch_stat varchar(10);
    declare dys_dff integer;
    declare rp_vl json;
    declare er_vl varchar(500);
	declare exit handler for sqlexception
	begin
		get diagnostics condition 1 @errno = mysql_errno, @text = message_text;
		set @err_msg = concat("ERR-", @errno, " : ", @text);
		select @err_msg into er_msg;
	end;

    if ref_num is not null and ref_num != '' then
        -- Get voucher's details
        select iss_dte, vld_prd, vch_stt into iss_dt, vch_tnr, vch_stat from prm_vch where vch_unq_ref = ref_num;

        if vch_stat = 'ACTIVE' then
            -- Compute the difference in days
            set dys_dff = datediff(curdate(), iss_dt);

            if dys_dff <= vch_tnr then
                call rtn_prd_lst('voucher_products', cast(ref_num as unsigned), @out, @err);
                select @out, @err into rp_vl, er_vl from dual;

                if rp_vl is not null and er_vl is null then
                    set pr_dt = rp_vl;
                elseif rp_vl is null and er_vl is not null then
                    set er_msg = er_vl;
                end if;
            else
                set pr_dt = json_object('message', 'Voucher is inactive');
            end if;
        else
            set pr_dt = json_object('message', 'Voucher is inactive');
        end if;
    else
        set er_msg = 'Arguments are null';
    end if;
end$$

DELIMITER ;


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

    if prd_rk is null or prd_rk = '' then
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
    declare csr_ctg_lst cursor for
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
    declare csr_bnr_lst cursor for
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
    declare vch_val decimal(21,2);
    declare vch_ext decimal(15,2);
    declare vch_amt_upb decimal(21,2);
    declare prd_obj json;
    declare prd_arr json default json_array();
    declare done integer default 0;
    declare csr_ctg_prd_lst cursor for
        select * from vw_prd_lst where ctg_id = ety_id;
    declare csr_prd_lst cursor for
        select * from vw_prd_lst;
    declare csr_prd_tp_sle cursor for
        select * from vw_prd_lst order by sale_cnt desc; 
    declare continue handler for not found set done = 1;
	declare exit handler for sqlexception
	begin
		get diagnostics condition 1 @errno = mysql_errno, @text = message_text;
		set @err_msg = concat("ERR-", @errno, " : ", @text);
		select @err_msg into er_msg;
	end;

    if (act_typ is null or act_typ = '') and (ety_id is null or ety_id = '') then
        set er_msg = 'Arguments are null';
    else
        case act_typ
            when 'voucher_products' then
                -- Retrieve the voucher amount and the extra amount for the upper bound
                select vch_amt, vch_alw into vch_val, vch_ext from prm_vch where vch_unq_ref = cast(ety_id as char);
                set vch_amt_upb = vch_val + vch_ext; -- Get the upper bound amount

                -- Get product list 
                open csr_prd_lst;

                loop1: loop
                    fetch csr_prd_lst into
                    prd_id, prd_ctg_id, ctg_nme, prd_nm, prd_det, prd_ttl, unt_prc, old_prc, dst_val, dst_amt, ext_dtls, qty_sld, prd_img, prd_sta, upd_dt;

                    if done = 1 then
                        leave loop1;
                    end if;

                    if unt_prc >= vch_val and unt_prc <= vch_amt_upb then 
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
                    end if;
                end loop loop1;

                close csr_prd_lst;
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