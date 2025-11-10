component axi2axil_M05 is
    port(
        clk: in std_logic;
        rst_n: in std_logic;
        s_axi_awid: in std_logic;
        s_axi_awaddr: in std_logic_vector(31 downto 0);
        s_axi_awlen: in std_logic_vector(7 downto 0);
        s_axi_awsize: in std_logic_vector(2 downto 0);
        s_axi_awburst: in std_logic_vector(1 downto 0);
        s_axi_awlock: in std_logic;
        s_axi_awcache: in std_logic_vector(3 downto 0);
        s_axi_awprot: in std_logic_vector(2 downto 0);
        s_axi_awqos: in std_logic_vector(3 downto 0);
        s_axi_awregion: in std_logic_vector(3 downto 0);
        s_axi_awvalid: in std_logic;
        s_axi_awready: out std_logic;
        s_axi_wdata: in std_logic_vector(31 downto 0);
        s_axi_wstrb: in std_logic_vector(3 downto 0);
        s_axi_wlast: in std_logic;
        s_axi_wvalid: in std_logic;
        s_axi_wready: out std_logic;
        s_axi_bid: out std_logic;
        s_axi_bresp: out std_logic_vector(1 downto 0);
        s_axi_bvalid: out std_logic;
        s_axi_bready: in std_logic;
        s_axi_arid: in std_logic;
        s_axi_araddr: in std_logic_vector(31 downto 0);
        s_axi_arlen: in std_logic_vector(7 downto 0);
        s_axi_arsize: in std_logic_vector(2 downto 0);
        s_axi_arburst: in std_logic_vector(1 downto 0);
        s_axi_arlock: in std_logic;
        s_axi_arcache: in std_logic_vector(3 downto 0);
        s_axi_arprot: in std_logic_vector(2 downto 0);
        s_axi_arqos: in std_logic_vector(3 downto 0);
        s_axi_arregion: in std_logic_vector(3 downto 0);
        s_axi_arvalid: in std_logic;
        s_axi_arready: out std_logic;
        s_axi_rid: out std_logic;
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
        m_axil_awaddr: out std_logic_vector(31 downto 0);
        m_axil_awprot: out std_logic_vector(2 downto 0);
        m_axil_awvalid: out std_logic;
        m_axil_awready: in std_logic;
        m_axil_wdata: out std_logic_vector(31 downto 0);
        m_axil_wstrb: out std_logic_vector(3 downto 0);
        m_axil_wvalid: out std_logic;
        m_axil_wready: in std_logic;
        m_axil_bresp: in std_logic_vector(1 downto 0);
        m_axil_bvalid: in std_logic;
        m_axil_bready: out std_logic;
        m_axil_araddr: out std_logic_vector(31 downto 0);
        m_axil_arprot: out std_logic_vector(2 downto 0);
        m_axil_arvalid: out std_logic;
        m_axil_arready: in std_logic;
        m_axil_rdata: in std_logic_vector(31 downto 0);
        m_axil_rresp: in std_logic_vector(1 downto 0);
        m_axil_rvalid: in std_logic;
        m_axil_rready: out std_logic
    );
end component;

__: axi2axil_M05 port map(
    clk=>,
    rst_n=>,
    s_axi_awid=>,
    s_axi_awaddr=>,
    s_axi_awlen=>,
    s_axi_awsize=>,
    s_axi_awburst=>,
    s_axi_awlock=>,
    s_axi_awcache=>,
    s_axi_awprot=>,
    s_axi_awqos=>,
    s_axi_awregion=>,
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
    s_axi_arregion=>,
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
    m_axil_awaddr=>,
    m_axil_awprot=>,
    m_axil_awvalid=>,
    m_axil_awready=>,
    m_axil_wdata=>,
    m_axil_wstrb=>,
    m_axil_wvalid=>,
    m_axil_wready=>,
    m_axil_bresp=>,
    m_axil_bvalid=>,
    m_axil_bready=>,
    m_axil_araddr=>,
    m_axil_arprot=>,
    m_axil_arvalid=>,
    m_axil_arready=>,
    m_axil_rdata=>,
    m_axil_rresp=>,
    m_axil_rvalid=>,
    m_axil_rready=>
);
