component hram_controller0 is
    port(
        clk_i: in std_logic;
        rst_n: in std_logic;
        hyperbus_clk_i: in std_logic;
        hyperbus_clk_m0_o: out std_logic_vector(0 to 0);
        hyperbus_csn_m0_o: out std_logic_vector(0 to 0);
        hyperbus_resetn_m0_o: out std_logic_vector(0 to 0);
        hyperbus_rwds_m0_io: inout std_logic_vector(0 to 0);
        hyperbus_dq_m0_io: inout std_logic_vector(7 downto 0);
        hyperbus_clk_m1_o: out std_logic_vector(0 to 0);
        hyperbus_csn_m1_o: out std_logic_vector(0 to 0);
        hyperbus_resetn_m1_o: out std_logic_vector(0 to 0);
        hyperbus_rwds_m1_io: inout std_logic_vector(0 to 0);
        hyperbus_dq_m1_io: inout std_logic_vector(7 downto 0);
        intr_o: out std_logic;
        s_axil_awvalid: in std_logic;
        s_axil_awready: out std_logic;
        s_axil_awaddr: in std_logic_vector(31 downto 0);
        s_axil_awprot: in std_logic_vector(2 downto 0);
        s_axil_wvalid: in std_logic;
        s_axil_wready: out std_logic;
        s_axil_wdata: in std_logic_vector(31 downto 0);
        s_axil_wstrb: in std_logic_vector(3 downto 0);
        s_axil_bvalid: out std_logic;
        s_axil_bready: in std_logic;
        s_axil_bresp: out std_logic_vector(1 downto 0);
        s_axil_arvalid: in std_logic;
        s_axil_arready: out std_logic;
        s_axil_araddr: in std_logic_vector(31 downto 0);
        s_axil_arprot: in std_logic_vector(2 downto 0);
        s_axil_rvalid: out std_logic;
        s_axil_rready: in std_logic;
        s_axil_rdata: out std_logic_vector(31 downto 0);
        s_axil_rresp: out std_logic_vector(1 downto 0);
        s_axi_awid: in std_logic_vector(3 downto 0);
        s_axi_awaddr: in std_logic_vector(31 downto 0);
        s_axi_awlen: in std_logic_vector(7 downto 0);
        s_axi_awsize: in std_logic_vector(2 downto 0);
        s_axi_awburst: in std_logic_vector(1 downto 0);
        s_axi_awlock: in std_logic;
        s_axi_awcache: in std_logic_vector(3 downto 0);
        s_axi_awprot: in std_logic_vector(2 downto 0);
        s_axi_awqos: in std_logic_vector(3 downto 0);
        s_axi_awvalid: in std_logic;
        s_axi_awready: out std_logic;
        s_axi_wdata: in std_logic_vector(31 downto 0);
        s_axi_wstrb: in std_logic_vector(3 downto 0);
        s_axi_wlast: in std_logic;
        s_axi_wvalid: in std_logic;
        s_axi_wready: out std_logic;
        s_axi_bid: out std_logic_vector(3 downto 0);
        s_axi_bresp: out std_logic_vector(1 downto 0);
        s_axi_bvalid: out std_logic;
        s_axi_bready: in std_logic;
        s_axi_arid: in std_logic_vector(3 downto 0);
        s_axi_araddr: in std_logic_vector(31 downto 0);
        s_axi_arlen: in std_logic_vector(7 downto 0);
        s_axi_arsize: in std_logic_vector(2 downto 0);
        s_axi_arburst: in std_logic_vector(1 downto 0);
        s_axi_arlock: in std_logic;
        s_axi_arcache: in std_logic_vector(3 downto 0);
        s_axi_arprot: in std_logic_vector(2 downto 0);
        s_axi_arqos: in std_logic_vector(3 downto 0);
        s_axi_arvalid: in std_logic;
        s_axi_arready: out std_logic;
        s_axi_rid: out std_logic_vector(3 downto 0);
        s_axi_rdata: out std_logic_vector(31 downto 0);
        s_axi_rresp: out std_logic_vector(1 downto 0);
        s_axi_rlast: out std_logic;
        s_axi_rvalid: out std_logic;
        s_axi_rready: in std_logic;
        s_axi_awuser: in std_logic;
        s_axi_wuser: in std_logic;
        s_axi_buser: out std_logic;
        s_axi_aruser: in std_logic;
        s_axi_ruser: out std_logic;
        hyperbus_clkn_m0_o: out std_logic_vector(0 to 0);
        hyperbus_clkn_m1_o: out std_logic_vector(0 to 0);
        hyperbus_clk270_i: in std_logic
    );
end component;

__: hram_controller0 port map(
    clk_i=>,
    rst_n=>,
    hyperbus_clk_i=>,
    hyperbus_clk_m0_o=>,
    hyperbus_csn_m0_o=>,
    hyperbus_resetn_m0_o=>,
    hyperbus_rwds_m0_io=>,
    hyperbus_dq_m0_io=>,
    hyperbus_clk_m1_o=>,
    hyperbus_csn_m1_o=>,
    hyperbus_resetn_m1_o=>,
    hyperbus_rwds_m1_io=>,
    hyperbus_dq_m1_io=>,
    intr_o=>,
    s_axil_awvalid=>,
    s_axil_awready=>,
    s_axil_awaddr=>,
    s_axil_awprot=>,
    s_axil_wvalid=>,
    s_axil_wready=>,
    s_axil_wdata=>,
    s_axil_wstrb=>,
    s_axil_bvalid=>,
    s_axil_bready=>,
    s_axil_bresp=>,
    s_axil_arvalid=>,
    s_axil_arready=>,
    s_axil_araddr=>,
    s_axil_arprot=>,
    s_axil_rvalid=>,
    s_axil_rready=>,
    s_axil_rdata=>,
    s_axil_rresp=>,
    s_axi_awid=>,
    s_axi_awaddr=>,
    s_axi_awlen=>,
    s_axi_awsize=>,
    s_axi_awburst=>,
    s_axi_awlock=>,
    s_axi_awcache=>,
    s_axi_awprot=>,
    s_axi_awqos=>,
    s_axi_awvalid=>,
    s_axi_awready=>,
    s_axi_wdata=>,
    s_axi_wstrb=>,
    s_axi_wlast=>,
    s_axi_wvalid=>,
    s_axi_wready=>,
    s_axi_bid=>,
    s_axi_bresp=>,
    s_axi_bvalid=>,
    s_axi_bready=>,
    s_axi_arid=>,
    s_axi_araddr=>,
    s_axi_arlen=>,
    s_axi_arsize=>,
    s_axi_arburst=>,
    s_axi_arlock=>,
    s_axi_arcache=>,
    s_axi_arprot=>,
    s_axi_arqos=>,
    s_axi_arvalid=>,
    s_axi_arready=>,
    s_axi_rid=>,
    s_axi_rdata=>,
    s_axi_rresp=>,
    s_axi_rlast=>,
    s_axi_rvalid=>,
    s_axi_rready=>,
    s_axi_awuser=>,
    s_axi_wuser=>,
    s_axi_buser=>,
    s_axi_aruser=>,
    s_axi_ruser=>,
    hyperbus_clkn_m0_o=>,
    hyperbus_clkn_m1_o=>,
    hyperbus_clk270_i=>
);
