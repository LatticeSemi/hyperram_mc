component cdc_M09 is
    port(
        S_AXI_ACLK: in std_logic;
        S_AXI_ARESETN: in std_logic;
        M_AXI_ACLK: in std_logic;
        M_AXI_ARESETN: out std_logic;
        S_AXI_AWID: in std_logic;
        S_AXI_AWADDR: in std_logic_vector(31 downto 0);
        S_AXI_AWLEN: in std_logic_vector(7 downto 0);
        S_AXI_AWSIZE: in std_logic_vector(2 downto 0);
        S_AXI_AWBURST: in std_logic_vector(1 downto 0);
        S_AXI_AWLOCK: in std_logic;
        S_AXI_AWCACHE: in std_logic_vector(3 downto 0);
        S_AXI_AWPROT: in std_logic_vector(2 downto 0);
        S_AXI_AWQOS: in std_logic_vector(3 downto 0);
        S_AXI_AWVALID: in std_logic;
        S_AXI_AWREADY: out std_logic;
        S_AXI_WDATA: in std_logic_vector(31 downto 0);
        S_AXI_WSTRB: in std_logic_vector(3 downto 0);
        S_AXI_WLAST: in std_logic;
        S_AXI_WVALID: in std_logic;
        S_AXI_WREADY: out std_logic;
        S_AXI_BID: out std_logic;
        S_AXI_BRESP: out std_logic_vector(1 downto 0);
        S_AXI_BVALID: out std_logic;
        S_AXI_BREADY: in std_logic;
        S_AXI_ARID: in std_logic;
        S_AXI_ARADDR: in std_logic_vector(31 downto 0);
        S_AXI_ARLEN: in std_logic_vector(7 downto 0);
        S_AXI_ARSIZE: in std_logic_vector(2 downto 0);
        S_AXI_ARBURST: in std_logic_vector(1 downto 0);
        S_AXI_ARLOCK: in std_logic;
        S_AXI_ARCACHE: in std_logic_vector(3 downto 0);
        S_AXI_ARPROT: in std_logic_vector(2 downto 0);
        S_AXI_ARQOS: in std_logic_vector(3 downto 0);
        S_AXI_ARVALID: in std_logic;
        S_AXI_ARREADY: out std_logic;
        S_AXI_RID: out std_logic;
        S_AXI_RDATA: out std_logic_vector(31 downto 0);
        S_AXI_RRESP: out std_logic_vector(1 downto 0);
        S_AXI_RLAST: out std_logic;
        S_AXI_RVALID: out std_logic;
        S_AXI_RREADY: in std_logic;
        s_axi_awuser: in std_logic;
        s_axi_wuser: in std_logic;
        s_axi_buser: out std_logic;
        s_axi_aruser: in std_logic;
        s_axi_ruser: out std_logic;
        M_AXI_AWID: out std_logic;
        M_AXI_AWADDR: out std_logic_vector(31 downto 0);
        M_AXI_AWLEN: out std_logic_vector(7 downto 0);
        M_AXI_AWSIZE: out std_logic_vector(2 downto 0);
        M_AXI_AWBURST: out std_logic_vector(1 downto 0);
        M_AXI_AWLOCK: out std_logic;
        M_AXI_AWCACHE: out std_logic_vector(3 downto 0);
        M_AXI_AWPROT: out std_logic_vector(2 downto 0);
        M_AXI_AWQOS: out std_logic_vector(3 downto 0);
        m_axi_awregion: out std_logic_vector(3 downto 0);
        m_axi_awuser: out std_logic;
        M_AXI_AWVALID: out std_logic;
        M_AXI_AWREADY: in std_logic_vector(0 to 0);
        M_AXI_WDATA: out std_logic_vector(31 downto 0);
        M_AXI_WSTRB: out std_logic_vector(3 downto 0);
        M_AXI_WLAST: out std_logic;
        m_axi_wuser: out std_logic;
        M_AXI_WVALID: out std_logic;
        M_AXI_WREADY: in std_logic;
        M_AXI_BID: in std_logic;
        M_AXI_BRESP: in std_logic_vector(1 downto 0);
        m_axi_buser: in std_logic;
        M_AXI_BVALID: in std_logic;
        M_AXI_BREADY: out std_logic;
        M_AXI_ARID: out std_logic;
        M_AXI_ARADDR: out std_logic_vector(31 downto 0);
        M_AXI_ARLEN: out std_logic_vector(7 downto 0);
        M_AXI_ARSIZE: out std_logic_vector(2 downto 0);
        M_AXI_ARBURST: out std_logic_vector(1 downto 0);
        M_AXI_ARLOCK: out std_logic;
        M_AXI_ARCACHE: out std_logic_vector(3 downto 0);
        M_AXI_ARPROT: out std_logic_vector(2 downto 0);
        M_AXI_ARQOS: out std_logic_vector(3 downto 0);
        m_axi_arregion: out std_logic_vector(3 downto 0);
        m_axi_aruser: out std_logic;
        M_AXI_ARVALID: out std_logic;
        M_AXI_ARREADY: in std_logic;
        M_AXI_RID: in std_logic;
        M_AXI_RDATA: in std_logic_vector(31 downto 0);
        M_AXI_RRESP: in std_logic_vector(1 downto 0);
        M_AXI_RLAST: in std_logic;
        m_axi_ruser: in std_logic;
        M_AXI_RVALID: in std_logic;
        M_AXI_RREADY: out std_logic
    );
end component;

__: cdc_M09 port map(
    S_AXI_ACLK=>,
    S_AXI_ARESETN=>,
    M_AXI_ACLK=>,
    M_AXI_ARESETN=>,
    S_AXI_AWID=>,
    S_AXI_AWADDR=>,
    S_AXI_AWLEN=>,
    S_AXI_AWSIZE=>,
    S_AXI_AWBURST=>,
    S_AXI_AWLOCK=>,
    S_AXI_AWCACHE=>,
    S_AXI_AWPROT=>,
    S_AXI_AWQOS=>,
    S_AXI_AWVALID=>,
    S_AXI_AWREADY=>,
    S_AXI_WDATA=>,
    S_AXI_WSTRB=>,
    S_AXI_WLAST=>,
    S_AXI_WVALID=>,
    S_AXI_WREADY=>,
    S_AXI_BID=>,
    S_AXI_BRESP=>,
    S_AXI_BVALID=>,
    S_AXI_BREADY=>,
    S_AXI_ARID=>,
    S_AXI_ARADDR=>,
    S_AXI_ARLEN=>,
    S_AXI_ARSIZE=>,
    S_AXI_ARBURST=>,
    S_AXI_ARLOCK=>,
    S_AXI_ARCACHE=>,
    S_AXI_ARPROT=>,
    S_AXI_ARQOS=>,
    S_AXI_ARVALID=>,
    S_AXI_ARREADY=>,
    S_AXI_RID=>,
    S_AXI_RDATA=>,
    S_AXI_RRESP=>,
    S_AXI_RLAST=>,
    S_AXI_RVALID=>,
    S_AXI_RREADY=>,
    s_axi_awuser=>,
    s_axi_wuser=>,
    s_axi_buser=>,
    s_axi_aruser=>,
    s_axi_ruser=>,
    M_AXI_AWID=>,
    M_AXI_AWADDR=>,
    M_AXI_AWLEN=>,
    M_AXI_AWSIZE=>,
    M_AXI_AWBURST=>,
    M_AXI_AWLOCK=>,
    M_AXI_AWCACHE=>,
    M_AXI_AWPROT=>,
    M_AXI_AWQOS=>,
    m_axi_awregion=>,
    m_axi_awuser=>,
    M_AXI_AWVALID=>,
    M_AXI_AWREADY=>,
    M_AXI_WDATA=>,
    M_AXI_WSTRB=>,
    M_AXI_WLAST=>,
    m_axi_wuser=>,
    M_AXI_WVALID=>,
    M_AXI_WREADY=>,
    M_AXI_BID=>,
    M_AXI_BRESP=>,
    m_axi_buser=>,
    M_AXI_BVALID=>,
    M_AXI_BREADY=>,
    M_AXI_ARID=>,
    M_AXI_ARADDR=>,
    M_AXI_ARLEN=>,
    M_AXI_ARSIZE=>,
    M_AXI_ARBURST=>,
    M_AXI_ARLOCK=>,
    M_AXI_ARCACHE=>,
    M_AXI_ARPROT=>,
    M_AXI_ARQOS=>,
    m_axi_arregion=>,
    m_axi_aruser=>,
    M_AXI_ARVALID=>,
    M_AXI_ARREADY=>,
    M_AXI_RID=>,
    M_AXI_RDATA=>,
    M_AXI_RRESP=>,
    M_AXI_RLAST=>,
    m_axi_ruser=>,
    M_AXI_RVALID=>,
    M_AXI_RREADY=>
);
