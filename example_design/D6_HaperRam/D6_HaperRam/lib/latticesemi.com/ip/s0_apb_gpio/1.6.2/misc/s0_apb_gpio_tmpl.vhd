component s0_apb_gpio is
    port(
        gpio_io: inout std_logic_vector(7 downto 0);
        clk_i: in std_logic;
        resetn_i: in std_logic;
        apb_penable_i: in std_logic;
        apb_psel_i: in std_logic;
        apb_pwrite_i: in std_logic;
        apb_paddr_i: in std_logic_vector(5 downto 0);
        apb_pwdata_i: in std_logic_vector(31 downto 0);
        apb_prdata_o: out std_logic_vector(31 downto 0);
        apb_pslverr_o: out std_logic;
        apb_pready_o: out std_logic;
        int_o: out std_logic
    );
end component;

__: s0_apb_gpio port map(
    gpio_io=>,
    clk_i=>,
    resetn_i=>,
    apb_penable_i=>,
    apb_psel_i=>,
    apb_pwrite_i=>,
    apb_paddr_i=>,
    apb_pwdata_i=>,
    apb_prdata_o=>,
    apb_pslverr_o=>,
    apb_pready_o=>,
    int_o=>
);
