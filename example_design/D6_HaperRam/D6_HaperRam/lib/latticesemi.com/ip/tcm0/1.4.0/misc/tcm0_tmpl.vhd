component tcm0 is
    port(
        sys_clk: in std_logic;
        sys_rst_n: in std_logic;
        ibus_cmd_valid: in std_logic;
        ibus_cmd_ready: out std_logic;
        ibus_cmd_payload_wr: in std_logic;
        ibus_cmd_payload_uncached: in std_logic;
        ibus_cmd_payload_address: in std_logic_vector(31 downto 0);
        ibus_cmd_payload_data: in std_logic_vector(31 downto 0);
        ibus_cmd_payload_mask: in std_logic_vector(3 downto 0);
        ibus_cmd_payload_size: in std_logic_vector(2 downto 0);
        ibus_cmd_payload_last: in std_logic;
        ibus_rsp_valid: out std_logic;
        ibus_rsp_payload_last: out std_logic;
        ibus_rsp_payload_data: out std_logic_vector(31 downto 0);
        ibus_rsp_payload_error: out std_logic;
        dbus_cmd_valid: in std_logic;
        dbus_cmd_ready: out std_logic;
        dbus_cmd_payload_wr: in std_logic;
        dbus_cmd_payload_uncached: in std_logic;
        dbus_cmd_payload_address: in std_logic_vector(31 downto 0);
        dbus_cmd_payload_data: in std_logic_vector(31 downto 0);
        dbus_cmd_payload_mask: in std_logic_vector(3 downto 0);
        dbus_cmd_payload_size: in std_logic_vector(2 downto 0);
        dbus_cmd_payload_last: in std_logic;
        dbus_rsp_valid: out std_logic;
        dbus_rsp_payload_last: out std_logic;
        dbus_rsp_payload_data: out std_logic_vector(31 downto 0);
        dbus_rsp_payload_error: out std_logic;
        dbus_rsp_payload_exclusive: out std_logic;
        dbus_cmd_payload_exclusive: in std_logic;
        dbus_inv_valid: out std_logic;
        dbus_inv_ready: in std_logic;
        dbus_inv_payload_last: out std_logic;
        dbus_inv_payload_fragment_enable: out std_logic;
        dbus_inv_payload_fragment_address: out std_logic_vector(31 downto 0);
        dbus_ack_valid: in std_logic;
        dbus_ack_ready: out std_logic;
        dbus_ack_payload_last: in std_logic;
        dbus_ack_payload_fragment_hit: in std_logic
    );
end component;

__: tcm0 port map(
    sys_clk=>,
    sys_rst_n=>,
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
    dbus_rsp_valid=>,
    dbus_rsp_payload_last=>,
    dbus_rsp_payload_data=>,
    dbus_rsp_payload_error=>,
    dbus_rsp_payload_exclusive=>,
    dbus_cmd_payload_exclusive=>,
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
