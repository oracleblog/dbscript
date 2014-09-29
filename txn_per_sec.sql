REM The script use for oracle 10g and 11g
REM
REM
select snap_id,to_char(end_interval_time, 'yyyy-mm-dd hh24:mi:ss') as end_interval_time,
       round(delta_transaction / delta_time, 0) as transaction_per_sec
  from (select snap_id,
               end_interval_time,
               (CAST(end_interval_time as date) -
               cast(lag(end_interval_time)
                     over(partition by startup_time order by snap_id) as date)) * 1440 * 60 as delta_time,
               value - lag(value) over(partition by startup_time order by snap_id) as delta_transaction
          from (select bb.snap_id,
                       bb.end_interval_time,
                       bb.startup_time,
                       sum(value) as value
                  from sys.WRH$_SYSSTAT aa, sys.WRM$_SNAPSHOT bb
                 where stat_id in (582481098, 3671147913)
                   and aa.snap_id = bb.snap_id
                 group by bb.snap_id, bb.end_interval_time, bb.startup_time))
                 where end_interval_time>=sysdate-120
/
