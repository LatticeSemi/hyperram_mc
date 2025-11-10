component s1_apb_uart is
    port(
        rxd_i: in std_logic;
        txd_o: out std_logic;
        clk_i: in std_logic;
        rst_n_i: in std_logic;
        int_o: out std_logic;
        apb_penable_i: in std_logic;
        apb_psel_i: in std_logic;
        apb_pwrite_i: in std_logic;
        apb_paddr_i: in std_logic_vector(5 downto 0);
        apb_pwdata_i: in std_logic_vector(31 downto 0);
        apb_pready_o: out std_logic;
        apb_pslverr_o: out std_logic;
        apb_prdata_o: out std_logic_vector(31 downto 0)
    );
end component;

__: s1_apb_uart port map(
    rxd_i=>,
    txd_o=>,
    clk_i=>,
    rst_n_i=>,
    int_o=>,
    apb_penable_i=>,
    apb_psel_i=>,
    apb_pwrite_i=>,
    apb_paddr_i=>,
    apb_pwdata_i=>,
    apb_pready_o=>,
    apb_pslverr_o=>,
    apb_prdata_o=>
);
