component system_cache0 is
    port(
        sys_rst_n: in std_logic;
        sys_clk: in std_logic;
        ibus0_cmd_valid: in std_logic;
        ibus0_cmd_ready: out std_logic;
        ibus0_cmd_payload_wr: in std_logic;
        ibus0_cmd_payload_address: in std_logic_vector(31 downto 0);
        ibus0_cmd_payload_data: in std_logic_vector(31 downto 0);
        ibus0_cmd_payload_mask: in std_logic_vector(3 downto 0);
        ibus0_cmd_payload_size: in std_logic_vector(2 downto 0);
        ibus0_cmd_payload_uncached: in std_logic;
        ibus0_cmd_payload_last: in std_logic;
        ibus0_rsp_valid: out std_logic;
        ibus0_rsp_payload_last: out std_logic;
        ibus0_rsp_payload_data: out std_logic_vector(31 downto 0);
        ibus0_rsp_payload_error: out std_logic;
        dbus0_cmd_valid: in std_logic;
        dbus0_cmd_ready: out std_logic;
        dbus0_cmd_payload_wr: in std_logic;
        dbus0_cmd_payload_address: in std_logic_vector(31 downto 0);
        dbus0_cmd_payload_data: in std_logic_vector(31 downto 0);
        dbus0_cmd_payload_mask: in std_logic_vector(3 downto 0);
        dbus0_cmd_payload_size: in std_logic_vector(2 downto 0);
        dbus0_cmd_payload_uncached: in std_logic;
        dbus0_cmd_payload_last: in std_logic;
        dbus0_cmd_payload_exclusive: in std_logic;
        dbus0_rsp_valid: out std_logic;
        dbus0_rsp_payload_last: out std_logic;
        dbus0_rsp_payload_data: out std_logic_vector(31 downto 0);
        dbus0_rsp_payload_error: out std_logic;
        dbus0_rsp_payload_exclusive: out std_logic;
        dbus0_inv_valid: out std_logic;
        dbus0_inv_ready: in std_logic;
        dbus0_inv_payload_last: out std_logic;
        dbus0_inv_payload_fragment_enable: out std_logic;
        dbus0_inv_payload_fragment_address: out std_logic_vector(31 downto 0);
        dbus0_ack_valid: in std_logic;
        dbus0_ack_ready: out std_logic;
        dbus0_ack_payload_last: in std_logic;
        dbus0_ack_payload_fragment_hit: in std_logic;
        dbus0_sync_valid: out std_logic;
        dbus0_sync_ready: in std_logic;
        axi_m_awid_o: out std_logic_vector(3 downto 0);
        axi_m_awaddr_o: out std_logic_vector(31 downto 0);
        axi_m_awlen_o: out std_logic_vector(7 downto 0);
        axi_m_awsize_o: out std_logic_vector(2 downto 0);
        axi_m_awburst_o: out std_logic_vector(1 downto 0);
        axi_m_awlock_o: out std_logic;
        axi_m_awcache_o: out std_logic_vector(3 downto 0);
        axi_m_awqos_o: out std_logic_vector(3 downto 0);
        axi_m_awregion_o: out std_logic_vector(3 downto 0);
        axi_m_awprot_o: out std_logic_vector(2 downto 0);
        axi_m_awvalid_o: out std_logic;
        axi_m_awready_i: in std_logic;
        axi_m_wdata_o: out std_logic_vector(31 downto 0);
        axi_m_wstrb_o: out std_logic_vector(3 downto 0);
        axi_m_wlast_o: out std_logic;
        axi_m_wvalid_o: out std_logic;
        axi_m_wready_i: in std_logic;
        axi_m_bid_i: in std_logic_vector(3 downto 0);
        axi_m_bresp_i: in std_logic_vector(1 downto 0);
        axi_m_bvalid_i: in std_logic;
        axi_m_arid_o: out std_logic_vector(3 downto 0);
        axi_m_araddr_o: out std_logic_vector(31 downto 0);
        axi_m_arlen_o: out std_logic_vector(7 downto 0);
        axi_m_arsize_o: out std_logic_vector(2 downto 0);
        axi_m_arburst_o: out std_logic_vector(1 downto 0);
        axi_m_arlock_o: out std_logic;
        axi_m_arcache_o: out std_logic_vector(3 downto 0);
        axi_m_arqos_o: out std_logic_vector(3 downto 0);
        axi_m_arregion_o: out std_logic_vector(3 downto 0);
        axi_m_arprot_o: out std_logic_vector(2 downto 0);
        axi_m_arvalid_o: out std_logic;
        axi_m_arready_i: in std_logic;
        axi_m_rid_i: in std_logic_vector(3 downto 0);
        axi_m_rdata_i: in std_logic_vector(31 downto 0);
        axi_m_rresp_i: in std_logic_vector(1 downto 0);
        axi_m_rlast_i: in std_logic;
        axi_m_rvalid_i: in std_logic;
        axi_m_rready_o: out std_logic;
        axi_m_bready_o: out std_logic;
        axi_lite_awaddr: in std_logic_vector(31 downto 0);
        axi_lite_awprot: in std_logic_vector(2 downto 0);
        axi_lite_awvalid: in std_logic;
        axi_lite_awready: out std_logic;
        axi_lite_wdata: in std_logic_vector(31 downto 0);
        axi_lite_wstrb: in std_logic_vector(3 downto 0);
        axi_lite_wvalid: in std_logic;
        axi_lite_wready: out std_logic;
        axi_lite_bvalid: out std_logic;
        axi_lite_bready: in std_logic;
        axi_lite_bresp: out std_logic_vector(1 downto 0);
        axi_lite_araddr: in std_logic_vector(31 downto 0);
        axi_lite_arprot: in std_logic_vector(2 downto 0);
        axi_lite_arvalid: in std_logic;
        axi_lite_arready: out std_logic;
        axi_lite_rvalid: out std_logic;
        axi_lite_rready: in std_logic;
        axi_lite_rresp: out std_logic_vector(1 downto 0);
        axi_lite_rdata: out std_logic_vector(31 downto 0)
    );
end component;

__: system_cache0 port map(
    sys_rst_n=>,
    sys_clk=>,
    ibus0_cmd_valid=>,
    ibus0_cmd_ready=>,
    ibus0_cmd_payload_wr=>,
    ibus0_cmd_payload_address=>,
    ibus0_cmd_payload_data=>,
    ibus0_cmd_payload_mask=>,
    ibus0_cmd_payload_size=>,
    ibus0_cmd_payload_uncached=>,
    ibus0_cmd_payload_last=>,
    ibus0_rsp_valid=>,
    ibus0_rsp_payload_last=>,
    ibus0_rsp_payload_data=>,
    ibus0_rsp_payload_error=>,
    dbus0_cmd_valid=>,
    dbus0_cmd_ready=>,
    dbus0_cmd_payload_wr=>,
    dbus0_cmd_payload_address=>,
    dbus0_cmd_payload_data=>,
    dbus0_cmd_payload_mask=>,
    dbus0_cmd_payload_size=>,
    dbus0_cmd_payload_uncached=>,
    dbus0_cmd_payload_last=>,
    dbus0_cmd_payload_exclusive=>,
    dbus0_rsp_valid=>,
    dbus0_rsp_payload_last=>,
    dbus0_rsp_payload_data=>,
    dbus0_rsp_payload_error=>,
    dbus0_rsp_payload_exclusive=>,
    dbus0_inv_valid=>,
    dbus0_inv_ready=>,
    dbus0_inv_payload_last=>,
    dbus0_inv_payload_fragment_enable=>,
    dbus0_inv_payload_fragment_address=>,
    dbus0_ack_valid=>,
    dbus0_ack_ready=>,
    dbus0_ack_payload_last=>,
    dbus0_ack_payload_fragment_hit=>,
    dbus0_sync_valid=>,
    dbus0_sync_ready=>,
    axi_m_awid_o=>,
    axi_m_awaddr_o=>,
    axi_m_awlen_o=>,
    axi_m_awsize_o=>,
    axi_m_awburst_o=>,
    axi_m_awlock_o=>,
    axi_m_awcache_o=>,
    axi_m_awqos_o=>,
    axi_m_awregion_o=>,
    axi_m_awprot_o=>,
    axi_m_awvalid_o=>,
    axi_m_awready_i=>,
    axi_m_wdata_o=>,
    axi_m_wstrb_o=>,
    axi_m_wlast_o=>,
    axi_m_wvalid_o=>,
    axi_m_wready_i=>,
    axi_m_bid_i=>,
    axi_m_bresp_i=>,
    axi_m_bvalid_i=>,
    axi_m_arid_o=>,
    axi_m_araddr_o=>,
    axi_m_arlen_o=>,
    axi_m_arsize_o=>,
    axi_m_arburst_o=>,
    axi_m_arlock_o=>,
    axi_m_arcache_o=>,
    axi_m_arqos_o=>,
    axi_m_arregion_o=>,
    axi_m_arprot_o=>,
    axi_m_arvalid_o=>,
    axi_m_arready_i=>,
    axi_m_rid_i=>,
    axi_m_rdata_i=>,
    axi_m_rresp_i=>,
    axi_m_rlast_i=>,
    axi_m_rvalid_i=>,
    axi_m_rready_o=>,
    axi_m_bready_o=>,
    axi_lite_awaddr=>,
    axi_lite_awprot=>,
    axi_lite_awvalid=>,
    axi_lite_awready=>,
    axi_lite_wdata=>,
    axi_lite_wstrb=>,
    axi_lite_wvalid=>,
    axi_lite_wready=>,
    axi_lite_bvalid=>,
    axi_lite_bready=>,
    axi_lite_bresp=>,
    axi_lite_araddr=>,
    axi_lite_arprot=>,
    axi_lite_arvalid=>,
    axi_lite_arready=>,
    axi_lite_rvalid=>,
    axi_lite_rready=>,
    axi_lite_rresp=>,
    axi_lite_rdata=>
);
