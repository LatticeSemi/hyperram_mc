component cpu0 is
    port(
        clk_system_i: in std_logic;
        clk_realtime_i: in std_logic;
        rstn_i: in std_logic;
        system_resetn_o: out std_logic;
        uart_rxd_i: in std_logic;
        uart_txd_o: out std_logic;
        irq3_i: in std_logic_vector(0 to 0);
        irq2_i: in std_logic_vector(0 to 0);
        dBusAxi_aw_payload_id: out std_logic_vector(3 downto 0);
        dBusAxi_aw_payload_addr: out std_logic_vector(31 downto 0);
        dBusAxi_aw_payload_len: out std_logic_vector(7 downto 0);
        dBusAxi_aw_payload_size: out std_logic_vector(2 downto 0);
        dBusAxi_aw_payload_burst: out std_logic_vector(1 downto 0);
        dBusAxi_aw_payload_lock: out std_logic;
        dBusAxi_aw_payload_cache: out std_logic_vector(3 downto 0);
        dBusAxi_aw_payload_prot: out std_logic_vector(2 downto 0);
        dBusAxi_aw_payload_qos: out std_logic_vector(3 downto 0);
        dBusAxi_aw_payload_region: out std_logic_vector(3 downto 0);
        dBusAxi_aw_valid: out std_logic;
        dBusAxi_aw_ready: in std_logic;
        dBusAxi_w_payload_data: out std_logic_vector(31 downto 0);
        dBusAxi_w_payload_strb: out std_logic_vector(3 downto 0);
        dBusAxi_w_payload_last: out std_logic;
        dBusAxi_w_valid: out std_logic;
        dBusAxi_w_ready: in std_logic;
        dBusAxi_b_payload_id: in std_logic_vector(3 downto 0);
        dBusAxi_b_payload_resp: in std_logic_vector(1 downto 0);
        dBusAxi_b_valid: in std_logic;
        dBusAxi_b_ready: out std_logic;
        dBusAxi_ar_payload_id: out std_logic_vector(3 downto 0);
        dBusAxi_ar_payload_addr: out std_logic_vector(31 downto 0);
        dBusAxi_ar_payload_len: out std_logic_vector(7 downto 0);
        dBusAxi_ar_payload_size: out std_logic_vector(2 downto 0);
        dBusAxi_ar_payload_burst: out std_logic_vector(1 downto 0);
        dBusAxi_ar_payload_lock: out std_logic;
        dBusAxi_ar_payload_cache: out std_logic_vector(3 downto 0);
        dBusAxi_ar_payload_prot: out std_logic_vector(2 downto 0);
        dBusAxi_ar_payload_qos: out std_logic_vector(3 downto 0);
        dBusAxi_ar_payload_region: out std_logic_vector(3 downto 0);
        dBusAxi_ar_valid: out std_logic;
        dBusAxi_ar_ready: in std_logic;
        dBusAxi_r_payload_id: in std_logic_vector(3 downto 0);
        dBusAxi_r_payload_data: in std_logic_vector(31 downto 0);
        dBusAxi_r_payload_resp: in std_logic_vector(1 downto 0);
        dBusAxi_r_payload_last: in std_logic;
        dBusAxi_r_valid: in std_logic;
        dBusAxi_r_ready: out std_logic;
        iBusAxi_aw_payload_id: out std_logic_vector(3 downto 0);
        iBusAxi_aw_payload_addr: out std_logic_vector(31 downto 0);
        iBusAxi_aw_payload_len: out std_logic_vector(7 downto 0);
        iBusAxi_aw_payload_size: out std_logic_vector(2 downto 0);
        iBusAxi_aw_payload_burst: out std_logic_vector(1 downto 0);
        iBusAxi_aw_payload_lock: out std_logic;
        iBusAxi_aw_payload_cache: out std_logic_vector(3 downto 0);
        iBusAxi_aw_payload_prot: out std_logic_vector(2 downto 0);
        iBusAxi_aw_payload_qos: out std_logic_vector(3 downto 0);
        iBusAxi_aw_payload_region: out std_logic_vector(3 downto 0);
        iBusAxi_aw_valid: out std_logic;
        iBusAxi_aw_ready: in std_logic;
        iBusAxi_w_payload_data: out std_logic_vector(31 downto 0);
        iBusAxi_w_payload_strb: out std_logic_vector(3 downto 0);
        iBusAxi_w_payload_last: out std_logic;
        iBusAxi_w_valid: out std_logic;
        iBusAxi_w_ready: in std_logic;
        iBusAxi_b_payload_id: in std_logic_vector(3 downto 0);
        iBusAxi_b_payload_resp: in std_logic_vector(1 downto 0);
        iBusAxi_b_valid: in std_logic;
        iBusAxi_b_ready: out std_logic;
        iBusAxi_ar_payload_id: out std_logic_vector(3 downto 0);
        iBusAxi_ar_payload_addr: out std_logic_vector(31 downto 0);
        iBusAxi_ar_payload_len: out std_logic_vector(7 downto 0);
        iBusAxi_ar_payload_size: out std_logic_vector(2 downto 0);
        iBusAxi_ar_payload_burst: out std_logic_vector(1 downto 0);
        iBusAxi_ar_payload_lock: out std_logic;
        iBusAxi_ar_payload_cache: out std_logic_vector(3 downto 0);
        iBusAxi_ar_payload_prot: out std_logic_vector(2 downto 0);
        iBusAxi_ar_payload_qos: out std_logic_vector(3 downto 0);
        iBusAxi_ar_payload_region: out std_logic_vector(3 downto 0);
        iBusAxi_ar_valid: out std_logic;
        iBusAxi_ar_ready: in std_logic;
        iBusAxi_r_payload_id: in std_logic_vector(3 downto 0);
        iBusAxi_r_payload_data: in std_logic_vector(31 downto 0);
        iBusAxi_r_payload_resp: in std_logic_vector(1 downto 0);
        iBusAxi_r_payload_last: in std_logic;
        iBusAxi_r_valid: in std_logic;
        iBusAxi_r_ready: out std_logic;
        ibus_cmd_valid: out std_logic;
        ibus_cmd_ready: in std_logic;
        ibus_cmd_payload_wr: out std_logic;
        ibus_cmd_payload_uncached: out std_logic;
        ibus_cmd_payload_address: out std_logic_vector(31 downto 0);
        ibus_cmd_payload_data: out std_logic_vector(31 downto 0);
        ibus_cmd_payload_mask: out std_logic_vector(3 downto 0);
        ibus_cmd_payload_size: out std_logic_vector(2 downto 0);
        ibus_cmd_payload_last: out std_logic;
        ibus_rsp_valid: in std_logic;
        ibus_rsp_payload_last: in std_logic;
        ibus_rsp_payload_data: in std_logic_vector(31 downto 0);
        ibus_rsp_payload_error: in std_logic;
        dbus_cmd_valid: out std_logic;
        dbus_cmd_ready: in std_logic;
        dbus_cmd_payload_wr: out std_logic;
        dbus_cmd_payload_uncached: out std_logic;
        dbus_cmd_payload_address: out std_logic_vector(31 downto 0);
        dbus_cmd_payload_data: out std_logic_vector(31 downto 0);
        dbus_cmd_payload_mask: out std_logic_vector(3 downto 0);
        dbus_cmd_payload_size: out std_logic_vector(2 downto 0);
        dbus_cmd_payload_last: out std_logic;
        dbus_cmd_payload_exclusive: out std_logic;
        dbus_rsp_valid: in std_logic;
        dbus_rsp_payload_last: in std_logic;
        dbus_rsp_payload_data: in std_logic_vector(31 downto 0);
        dbus_rsp_payload_error: in std_logic;
        dbus_rsp_payload_exclusive: in std_logic;
        dbus_inv_valid: in std_logic;
        dbus_inv_ready: out std_logic;
        dbus_inv_payload_last: in std_logic;
        dbus_inv_payload_fragment_enable: in std_logic;
        dbus_inv_payload_fragment_address: in std_logic_vector(31 downto 0);
        dbus_ack_valid: out std_logic;
        dbus_ack_ready: in std_logic;
        dbus_ack_payload_last: out std_logic;
        dbus_ack_payload_fragment_hit: out std_logic
    );
end component;

__: cpu0 port map(
    clk_system_i=>,
    clk_realtime_i=>,
    rstn_i=>,
    system_resetn_o=>,
    uart_rxd_i=>,
    uart_txd_o=>,
    irq3_i=>,
    irq2_i=>,
    dBusAxi_aw_payload_id=>,
    dBusAxi_aw_payload_addr=>,
    dBusAxi_aw_payload_len=>,
    dBusAxi_aw_payload_size=>,
    dBusAxi_aw_payload_burst=>,
    dBusAxi_aw_payload_lock=>,
    dBusAxi_aw_payload_cache=>,
    dBusAxi_aw_payload_prot=>,
    dBusAxi_aw_payload_qos=>,
    dBusAxi_aw_payload_region=>,
    dBusAxi_aw_valid=>,
    dBusAxi_aw_ready=>,
    dBusAxi_w_payload_data=>,
    dBusAxi_w_payload_strb=>,
    dBusAxi_w_payload_last=>,
    dBusAxi_w_valid=>,
    dBusAxi_w_ready=>,
    dBusAxi_b_payload_id=>,
    dBusAxi_b_payload_resp=>,
    dBusAxi_b_valid=>,
    dBusAxi_b_ready=>,
    dBusAxi_ar_payload_id=>,
    dBusAxi_ar_payload_addr=>,
    dBusAxi_ar_payload_len=>,
    dBusAxi_ar_payload_size=>,
    dBusAxi_ar_payload_burst=>,
    dBusAxi_ar_payload_lock=>,
    dBusAxi_ar_payload_cache=>,
    dBusAxi_ar_payload_prot=>,
    dBusAxi_ar_payload_qos=>,
    dBusAxi_ar_payload_region=>,
    dBusAxi_ar_valid=>,
    dBusAxi_ar_ready=>,
    dBusAxi_r_payload_id=>,
    dBusAxi_r_payload_data=>,
    dBusAxi_r_payload_resp=>,
    dBusAxi_r_payload_last=>,
    dBusAxi_r_valid=>,
    dBusAxi_r_ready=>,
    iBusAxi_aw_payload_id=>,
    iBusAxi_aw_payload_addr=>,
    iBusAxi_aw_payload_len=>,
    iBusAxi_aw_payload_size=>,
    iBusAxi_aw_payload_burst=>,
    iBusAxi_aw_payload_lock=>,
    iBusAxi_aw_payload_cache=>,
    iBusAxi_aw_payload_prot=>,
    iBusAxi_aw_payload_qos=>,
    iBusAxi_aw_payload_region=>,
    iBusAxi_aw_valid=>,
    iBusAxi_aw_ready=>,
    iBusAxi_w_payload_data=>,
    iBusAxi_w_payload_strb=>,
    iBusAxi_w_payload_last=>,
    iBusAxi_w_valid=>,
    iBusAxi_w_ready=>,
    iBusAxi_b_payload_id=>,
    iBusAxi_b_payload_resp=>,
    iBusAxi_b_valid=>,
    iBusAxi_b_ready=>,
    iBusAxi_ar_payload_id=>,
    iBusAxi_ar_payload_addr=>,
    iBusAxi_ar_payload_len=>,
    iBusAxi_ar_payload_size=>,
    iBusAxi_ar_payload_burst=>,
    iBusAxi_ar_payload_lock=>,
    iBusAxi_ar_payload_cache=>,
    iBusAxi_ar_payload_prot=>,
    iBusAxi_ar_payload_qos=>,
    iBusAxi_ar_payload_region=>,
    iBusAxi_ar_valid=>,
    iBusAxi_ar_ready=>,
    iBusAxi_r_payload_id=>,
    iBusAxi_r_payload_data=>,
    iBusAxi_r_payload_resp=>,
    iBusAxi_r_payload_last=>,
    iBusAxi_r_valid=>,
    iBusAxi_r_ready=>,
    ibus_cmd_valid=>,
    ibus_cmd_ready=>,
    ibus_cmd_payload_wr=>,
    ibus_cmd_payload_uncached=>,
    ibus_cmd_payload_address=>,
    ibus_cmd_payload_data=>,
    ibus_cmd_payload_mask=>,
    ibus_cmd_payload_size=>,
    ibus_cmd_payload_last=>,
    ibus_rsp_valid=>,
    ibus_rsp_payload_last=>,
    ibus_rsp_payload_data=>,
    ibus_rsp_payload_error=>,
    dbus_cmd_valid=>,
    dbus_cmd_ready=>,
    dbus_cmd_payload_wr=>,
    dbus_cmd_payload_uncached=>,
    dbus_cmd_payload_address=>,
    dbus_cmd_payload_data=>,
    dbus_cmd_payload_mask=>,
    dbus_cmd_payload_size=>,
    dbus_cmd_payload_last=>,
    dbus_cmd_payload_exclusive=>,
    dbus_rsp_valid=>,
    dbus_rsp_payload_last=>,
    dbus_rsp_payload_data=>,
    dbus_rsp_payload_error=>,
    dbus_rsp_payload_exclusive=>,
    dbus_inv_valid=>,
    dbus_inv_ready=>,
    dbus_inv_payload_last=>,
    dbus_inv_payload_fragment_enable=>,
    dbus_inv_payload_fragment_address=>,
    dbus_ack_valid=>,
    dbus_ack_ready=>,
    dbus_ack_payload_last=>,
    dbus_ack_payload_fragment_hit=>
);
