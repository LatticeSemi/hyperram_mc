component axi_dma1 is
    port(
        clk: in std_logic;
        rst_n: in std_logic;
        s_axis_write_data_tdata: in std_logic_vector(31 downto 0);
        s_axis_write_data_tkeep: in std_logic_vector(3 downto 0);
        s_axis_write_data_tvalid: in std_logic;
        s_axis_write_data_tready: out std_logic;
        s_axis_write_data_tlast: in std_logic;
        s_axis_write_data_tid: in std_logic_vector(0 to 0);
        s_axis_write_data_tdest: in std_logic_vector(1 downto 0);
        s_axis_write_data_tuser: in std_logic_vector(0 to 0);
        m_axis_read_data_tdata: out std_logic_vector(31 downto 0);
        m_axis_read_data_tkeep: out std_logic_vector(3 downto 0);
        m_axis_read_data_tvalid: out std_logic;
        m_axis_read_data_tready: in std_logic;
        m_axis_read_data_tlast: out std_logic;
        m_axis_read_data_tid: out std_logic_vector(0 to 0);
        m_axis_read_data_tdest: out std_logic_vector(1 downto 0);
        m_axis_read_data_tuser: out std_logic_vector(0 to 0);
        S_AXI_AWVALID: in std_logic;
        S_AXI_AWREADY: out std_logic;
        S_AXI_AWADDR: in std_logic_vector(4 downto 0);
        S_AXI_AWPROT: in std_logic_vector(2 downto 0);
        S_AXI_WVALID: in std_logic;
        S_AXI_WREADY: out std_logic;
        S_AXI_WDATA: in std_logic_vector(31 downto 0);
        S_AXI_WSTRB: in std_logic_vector(3 downto 0);
        S_AXI_BVALID: out std_logic;
        S_AXI_BREADY: in std_logic;
        S_AXI_BRESP: out std_logic_vector(1 downto 0);
        S_AXI_ARVALID: in std_logic;
        S_AXI_ARREADY: out std_logic;
        S_AXI_ARADDR: in std_logic_vector(4 downto 0);
        S_AXI_ARPROT: in std_logic_vector(2 downto 0);
        S_AXI_RVALID: out std_logic;
        S_AXI_RREADY: in std_logic;
        S_AXI_RDATA: out std_logic_vector(31 downto 0);
        S_AXI_RRESP: out std_logic_vector(1 downto 0);
        m_axi_awid: out std_logic_vector(1 downto 0);
        m_axi_awaddr: out std_logic_vector(31 downto 0);
        m_axi_awlen: out std_logic_vector(7 downto 0);
        m_axi_awsize: out std_logic_vector(2 downto 0);
        m_axi_awburst: out std_logic_vector(1 downto 0);
        m_axi_awlock: out std_logic;
        m_axi_awcache: out std_logic_vector(3 downto 0);
        m_axi_awprot: out std_logic_vector(2 downto 0);
        m_axi_awvalid: out std_logic;
        m_axi_awready: in std_logic;
        m_axi_wdata: out std_logic_vector(31 downto 0);
        m_axi_wstrb: out std_logic_vector(3 downto 0);
        m_axi_wlast: out std_logic;
        m_axi_wvalid: out std_logic;
        m_axi_wready: in std_logic;
        m_axi_bid: in std_logic_vector(1 downto 0);
        m_axi_bresp: in std_logic_vector(1 downto 0);
        m_axi_bvalid: in std_logic;
        m_axi_bready: out std_logic;
        m_axi_arid: out std_logic_vector(1 downto 0);
        m_axi_araddr: out std_logic_vector(31 downto 0);
        m_axi_arlen: out std_logic_vector(7 downto 0);
        m_axi_arsize: out std_logic_vector(2 downto 0);
        m_axi_arburst: out std_logic_vector(1 downto 0);
        m_axi_arlock: out std_logic;
        m_axi_arcache: out std_logic_vector(3 downto 0);
        m_axi_arprot: out std_logic_vector(2 downto 0);
        m_axi_arvalid: out std_logic;
        m_axi_arready: in std_logic;
        m_axi_rid: in std_logic_vector(1 downto 0);
        m_axi_rdata: in std_logic_vector(31 downto 0);
        m_axi_rresp: in std_logic_vector(1 downto 0);
        m_axi_rlast: in std_logic;
        m_axi_rvalid: in std_logic;
        m_axi_rready: out std_logic
    );
end component;

__: axi_dma1 port map(
    clk=>,
    rst_n=>,
    s_axis_write_data_tdata=>,
    s_axis_write_data_tkeep=>,
    s_axis_write_data_tvalid=>,
    s_axis_write_data_tready=>,
    s_axis_write_data_tlast=>,
    s_axis_write_data_tid=>,
    s_axis_write_data_tdest=>,
    s_axis_write_data_tuser=>,
    m_axis_read_data_tdata=>,
    m_axis_read_data_tkeep=>,
    m_axis_read_data_tvalid=>,
    m_axis_read_data_tready=>,
    m_axis_read_data_tlast=>,
    m_axis_read_data_tid=>,
    m_axis_read_data_tdest=>,
    m_axis_read_data_tuser=>,
    S_AXI_AWVALID=>,
    S_AXI_AWREADY=>,
    S_AXI_AWADDR=>,
    S_AXI_AWPROT=>,
    S_AXI_WVALID=>,
    S_AXI_WREADY=>,
    S_AXI_WDATA=>,
    S_AXI_WSTRB=>,
    S_AXI_BVALID=>,
    S_AXI_BREADY=>,
    S_AXI_BRESP=>,
    S_AXI_ARVALID=>,
    S_AXI_ARREADY=>,
    S_AXI_ARADDR=>,
    S_AXI_ARPROT=>,
    S_AXI_RVALID=>,
    S_AXI_RREADY=>,
    S_AXI_RDATA=>,
    S_AXI_RRESP=>,
    m_axi_awid=>,
    m_axi_awaddr=>,
    m_axi_awlen=>,
    m_axi_awsize=>,
    m_axi_awburst=>,
    m_axi_awlock=>,
    m_axi_awcache=>,
    m_axi_awprot=>,
    m_axi_awvalid=>,
    m_axi_awready=>,
    m_axi_wdata=>,
    m_axi_wstrb=>,
    m_axi_wlast=>,
    m_axi_wvalid=>,
    m_axi_wready=>,
    m_axi_bid=>,
    m_axi_bresp=>,
    m_axi_bvalid=>,
    m_axi_bready=>,
    m_axi_arid=>,
    m_axi_araddr=>,
    m_axi_arlen=>,
    m_axi_arsize=>,
    m_axi_arburst=>,
    m_axi_arlock=>,
    m_axi_arcache=>,
    m_axi_arprot=>,
    m_axi_arvalid=>,
    m_axi_arready=>,
    m_axi_rid=>,
    m_axi_rdata=>,
    m_axi_rresp=>,
    m_axi_rlast=>,
    m_axi_rvalid=>,
    m_axi_rready=>
);
