component axi2ahbl0 is
    port(
        aclk_i: in std_logic;
        aresetn_i: in std_logic;
        ahb_mas_sel_o: out std_logic_vector(0 to 0);
        ahb_mas_addr_o: out std_logic_vector(31 downto 0);
        ahb_mas_write_o: out std_logic_vector(0 to 0);
        ahb_mas_wdata_o: out std_logic_vector(31 downto 0);
        ahb_mas_size_o: out std_logic_vector(2 downto 0);
        ahb_mas_trans_o: out std_logic_vector(1 downto 0);
        ahb_mas_burst_o: out std_logic_vector(2 downto 0);
        ahb_mas_prot_o: out std_logic_vector(3 downto 0);
        ahb_mas_ready_o: out std_logic_vector(0 to 0);
        ahb_mas_ready_i: in std_logic_vector(0 to 0);
        ahb_mas_rdata_i: in std_logic_vector(31 downto 0);
        ahb_mas_resp_i: in std_logic_vector(0 to 0);
        ahb_mas_mastlock_o: out std_logic_vector(0 to 0);
        axi_slv_awvalid_i: in std_logic_vector(0 to 0);
        axi_slv_awready_o: out std_logic_vector(0 to 0);
        axi_slv_awaddr_i: in std_logic_vector(31 downto 0);
        axi_slv_awsize_i: in std_logic_vector(2 downto 0);
        axi_slv_awburst_i: in std_logic_vector(1 downto 0);
        axi_slv_awlock_i: in std_logic_vector(0 to 0);
        axi_slv_awlen_i: in std_logic_vector(7 downto 0);
        axi_slv_awid_i: in std_logic_vector(3 downto 0);
        axi_slv_awprot_i: in std_logic_vector(2 downto 0);
        axi_slv_awcache_i: in std_logic_vector(3 downto 0);
        axi_slv_awqos_i: in std_logic_vector(3 downto 0);
        axi_slv_awregion_i: in std_logic_vector(3 downto 0);
        axi_slv_awuser_i: in std_logic_vector(0 to 0);
        axi_slv_wvalid_i: in std_logic_vector(0 to 0);
        axi_slv_wdata_i: in std_logic_vector(31 downto 0);
        axi_slv_wlast_i: in std_logic_vector(0 to 0);
        axi_slv_wuser_i: in std_logic_vector(0 to 0);
        axi_slv_wstrb_i: in std_logic_vector(3 downto 0);
        axi_slv_wready_o: out std_logic_vector(0 to 0);
        axi_slv_bvalid_o: out std_logic_vector(0 to 0);
        axi_slv_bready_i: in std_logic_vector(0 to 0);
        axi_slv_bresp_o: out std_logic_vector(1 downto 0);
        axi_slv_buser_o: out std_logic_vector(0 to 0);
        axi_slv_bid_o: out std_logic_vector(3 downto 0);
        axi_slv_arvalid_i: in std_logic_vector(0 to 0);
        axi_slv_arready_o: out std_logic_vector(0 to 0);
        axi_slv_araddr_i: in std_logic_vector(31 downto 0);
        axi_slv_arsize_i: in std_logic_vector(2 downto 0);
        axi_slv_arburst_i: in std_logic_vector(1 downto 0);
        axi_slv_arlock_i: in std_logic_vector(0 to 0);
        axi_slv_arlen_i: in std_logic_vector(7 downto 0);
        axi_slv_arid_i: in std_logic_vector(3 downto 0);
        axi_slv_arprot_i: in std_logic_vector(2 downto 0);
        axi_slv_arcache_i: in std_logic_vector(3 downto 0);
        axi_slv_arqos_i: in std_logic_vector(3 downto 0);
        axi_slv_arregion_i: in std_logic_vector(3 downto 0);
        axi_slv_aruser_i: in std_logic_vector(0 to 0);
        axi_slv_rvalid_o: out std_logic_vector(0 to 0);
        axi_slv_rready_i: in std_logic_vector(0 to 0);
        axi_slv_rdata_o: out std_logic_vector(31 downto 0);
        axi_slv_rlast_o: out std_logic_vector(0 to 0);
        axi_slv_rresp_o: out std_logic_vector(1 downto 0);
        axi_slv_ruser_o: out std_logic_vector(0 to 0);
        axi_slv_rid_o: out std_logic_vector(3 downto 0)
    );
end component;

__: axi2ahbl0 port map(
    aclk_i=>,
    aresetn_i=>,
    ahb_mas_sel_o=>,
    ahb_mas_addr_o=>,
    ahb_mas_write_o=>,
    ahb_mas_wdata_o=>,
    ahb_mas_size_o=>,
    ahb_mas_trans_o=>,
    ahb_mas_burst_o=>,
    ahb_mas_prot_o=>,
    ahb_mas_ready_o=>,
    ahb_mas_ready_i=>,
    ahb_mas_rdata_i=>,
    ahb_mas_resp_i=>,
    ahb_mas_mastlock_o=>,
    axi_slv_awvalid_i=>,
    axi_slv_awready_o=>,
    axi_slv_awaddr_i=>,
    axi_slv_awsize_i=>,
    axi_slv_awburst_i=>,
    axi_slv_awlock_i=>,
    axi_slv_awlen_i=>,
    axi_slv_awid_i=>,
    axi_slv_awprot_i=>,
    axi_slv_awcache_i=>,
    axi_slv_awqos_i=>,
    axi_slv_awregion_i=>,
    axi_slv_awuser_i=>,
    axi_slv_wvalid_i=>,
    axi_slv_wdata_i=>,
    axi_slv_wlast_i=>,
    axi_slv_wuser_i=>,
    axi_slv_wstrb_i=>,
    axi_slv_wready_o=>,
    axi_slv_bvalid_o=>,
    axi_slv_bready_i=>,
    axi_slv_bresp_o=>,
    axi_slv_buser_o=>,
    axi_slv_bid_o=>,
    axi_slv_arvalid_i=>,
    axi_slv_arready_o=>,
    axi_slv_araddr_i=>,
    axi_slv_arsize_i=>,
    axi_slv_arburst_i=>,
    axi_slv_arlock_i=>,
    axi_slv_arlen_i=>,
    axi_slv_arid_i=>,
    axi_slv_arprot_i=>,
    axi_slv_arcache_i=>,
    axi_slv_arqos_i=>,
    axi_slv_arregion_i=>,
    axi_slv_aruser_i=>,
    axi_slv_rvalid_o=>,
    axi_slv_rready_i=>,
    axi_slv_rdata_o=>,
    axi_slv_rlast_o=>,
    axi_slv_rresp_o=>,
    axi_slv_ruser_o=>,
    axi_slv_rid_o=>
);
