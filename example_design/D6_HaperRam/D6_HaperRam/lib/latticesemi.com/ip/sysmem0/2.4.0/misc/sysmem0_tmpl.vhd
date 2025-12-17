component sysmem0 is
    port(
        axi_aclk_i: in std_logic;
        axi_resetn_i: in std_logic;
        axi_s0_awaddr_i: in std_logic_vector(31 downto 0);
        axi_s0_awvalid_i: in std_logic;
        axi_s0_awprot_i: in std_logic_vector(2 downto 0);
        axi_s0_awready_o: out std_logic;
        axi_s0_awid_i: in std_logic_vector(3 downto 0);
        axi_s0_awlen_i: in std_logic_vector(7 downto 0);
        axi_s0_awsize_i: in std_logic_vector(2 downto 0);
        axi_s0_awburst_i: in std_logic_vector(1 downto 0);
        axi_s0_awlock_i: in std_logic;
        axi_s0_awcache_i: in std_logic_vector(3 downto 0);
        axi_s0_awqos_i: in std_logic_vector(3 downto 0);
        axi_s0_awregion_i: in std_logic_vector(3 downto 0);
        axi_s0_wdata_i: in std_logic_vector(31 downto 0);
        axi_s0_wstrb_i: in std_logic_vector(3 downto 0);
        axi_s0_wvalid_i: in std_logic;
        axi_s0_wready_o: out std_logic;
        axi_s0_wlast_i: in std_logic;
        axi_s0_bready_i: in std_logic;
        axi_s0_bresp_o: out std_logic_vector(1 downto 0);
        axi_s0_bvalid_o: out std_logic;
        axi_s0_bid_o: out std_logic_vector(3 downto 0);
        axi_s0_araddr_i: in std_logic_vector(31 downto 0);
        axi_s0_arvalid_i: in std_logic;
        axi_s0_arprot_i: in std_logic_vector(2 downto 0);
        axi_s0_arready_o: out std_logic;
        axi_s0_arid_i: in std_logic_vector(3 downto 0);
        axi_s0_arlen_i: in std_logic_vector(7 downto 0);
        axi_s0_arsize_i: in std_logic_vector(2 downto 0);
        axi_s0_arburst_i: in std_logic_vector(1 downto 0);
        axi_s0_arlock_i: in std_logic;
        axi_s0_arcache_i: in std_logic_vector(3 downto 0);
        axi_s0_arqos_i: in std_logic_vector(3 downto 0);
        axi_s0_arregion_i: in std_logic_vector(3 downto 0);
        axi_s0_rdata_o: out std_logic_vector(31 downto 0);
        axi_s0_rready_i: in std_logic;
        axi_s0_rresp_o: out std_logic_vector(1 downto 0);
        axi_s0_rvalid_o: out std_logic;
        axi_s0_rid_o: out std_logic_vector(3 downto 0);
        axi_s0_rlast_o: out std_logic;
        axi_s1_awaddr_i: in std_logic_vector(31 downto 0);
        axi_s1_awvalid_i: in std_logic;
        axi_s1_awprot_i: in std_logic_vector(2 downto 0);
        axi_s1_awready_o: out std_logic;
        axi_s1_awid_i: in std_logic_vector(3 downto 0);
        axi_s1_awlen_i: in std_logic_vector(7 downto 0);
        axi_s1_awsize_i: in std_logic_vector(2 downto 0);
        axi_s1_awburst_i: in std_logic_vector(1 downto 0);
        axi_s1_awlock_i: in std_logic;
        axi_s1_awcache_i: in std_logic_vector(3 downto 0);
        axi_s1_awqos_i: in std_logic_vector(3 downto 0);
        axi_s1_awregion_i: in std_logic_vector(3 downto 0);
        axi_s1_wdata_i: in std_logic_vector(31 downto 0);
        axi_s1_wstrb_i: in std_logic_vector(3 downto 0);
        axi_s1_wvalid_i: in std_logic;
        axi_s1_wready_o: out std_logic;
        axi_s1_wlast_i: in std_logic;
        axi_s1_bready_i: in std_logic;
        axi_s1_bresp_o: out std_logic_vector(1 downto 0);
        axi_s1_bvalid_o: out std_logic;
        axi_s1_bid_o: out std_logic_vector(3 downto 0);
        axi_s1_araddr_i: in std_logic_vector(31 downto 0);
        axi_s1_arvalid_i: in std_logic;
        axi_s1_arprot_i: in std_logic_vector(2 downto 0);
        axi_s1_arready_o: out std_logic;
        axi_s1_arid_i: in std_logic_vector(3 downto 0);
        axi_s1_arlen_i: in std_logic_vector(7 downto 0);
        axi_s1_arsize_i: in std_logic_vector(2 downto 0);
        axi_s1_arburst_i: in std_logic_vector(1 downto 0);
        axi_s1_arlock_i: in std_logic;
        axi_s1_arcache_i: in std_logic_vector(3 downto 0);
        axi_s1_arqos_i: in std_logic_vector(3 downto 0);
        axi_s1_arregion_i: in std_logic_vector(3 downto 0);
        axi_s1_rdata_o: out std_logic_vector(31 downto 0);
        axi_s1_rready_i: in std_logic;
        axi_s1_rresp_o: out std_logic_vector(1 downto 0);
        axi_s1_rvalid_o: out std_logic;
        axi_s1_rid_o: out std_logic_vector(3 downto 0);
        axi_s1_rlast_o: out std_logic
    );
end component;

__: sysmem0 port map(
    axi_aclk_i=>,
    axi_resetn_i=>,
    axi_s0_awaddr_i=>,
    axi_s0_awvalid_i=>,
    axi_s0_awprot_i=>,
    axi_s0_awready_o=>,
    axi_s0_awid_i=>,
    axi_s0_awlen_i=>,
    axi_s0_awsize_i=>,
    axi_s0_awburst_i=>,
    axi_s0_awlock_i=>,
    axi_s0_awcache_i=>,
    axi_s0_awqos_i=>,
    axi_s0_awregion_i=>,
    axi_s0_wdata_i=>,
    axi_s0_wstrb_i=>,
    axi_s0_wvalid_i=>,
    axi_s0_wready_o=>,
    axi_s0_wlast_i=>,
    axi_s0_bready_i=>,
    axi_s0_bresp_o=>,
    axi_s0_bvalid_o=>,
    axi_s0_bid_o=>,
    axi_s0_araddr_i=>,
    axi_s0_arvalid_i=>,
    axi_s0_arprot_i=>,
    axi_s0_arready_o=>,
    axi_s0_arid_i=>,
    axi_s0_arlen_i=>,
    axi_s0_arsize_i=>,
    axi_s0_arburst_i=>,
    axi_s0_arlock_i=>,
    axi_s0_arcache_i=>,
    axi_s0_arqos_i=>,
    axi_s0_arregion_i=>,
    axi_s0_rdata_o=>,
    axi_s0_rready_i=>,
    axi_s0_rresp_o=>,
    axi_s0_rvalid_o=>,
    axi_s0_rid_o=>,
    axi_s0_rlast_o=>,
    axi_s1_awaddr_i=>,
    axi_s1_awvalid_i=>,
    axi_s1_awprot_i=>,
    axi_s1_awready_o=>,
    axi_s1_awid_i=>,
    axi_s1_awlen_i=>,
    axi_s1_awsize_i=>,
    axi_s1_awburst_i=>,
    axi_s1_awlock_i=>,
    axi_s1_awcache_i=>,
    axi_s1_awqos_i=>,
    axi_s1_awregion_i=>,
    axi_s1_wdata_i=>,
    axi_s1_wstrb_i=>,
    axi_s1_wvalid_i=>,
    axi_s1_wready_o=>,
    axi_s1_wlast_i=>,
    axi_s1_bready_i=>,
    axi_s1_bresp_o=>,
    axi_s1_bvalid_o=>,
    axi_s1_bid_o=>,
    axi_s1_araddr_i=>,
    axi_s1_arvalid_i=>,
    axi_s1_arprot_i=>,
    axi_s1_arready_o=>,
    axi_s1_arid_i=>,
    axi_s1_arlen_i=>,
    axi_s1_arsize_i=>,
    axi_s1_arburst_i=>,
    axi_s1_arlock_i=>,
    axi_s1_arcache_i=>,
    axi_s1_arqos_i=>,
    axi_s1_arregion_i=>,
    axi_s1_rdata_o=>,
    axi_s1_rready_i=>,
    axi_s1_rresp_o=>,
    axi_s1_rvalid_o=>,
    axi_s1_rid_o=>,
    axi_s1_rlast_o=>
);
