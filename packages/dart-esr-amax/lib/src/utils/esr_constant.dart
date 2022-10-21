enum ChainName {
  UNKNOWN,
  AMAX,
  AMAX_TEST,
  EOS,
  EOS_JUNGLE2,
  TELOS,
  JUNGLE,
  KYLIN,
  WORBLI,
  BOS,
  MEETONE,
  INSIGHTS,
  BEOS,
  WAX,
  PROTON,
  FIO,
  EOS_JUNGLE3,
}

class ESRConstants {
  //const AbiTypes = Serialize.getTypesFromAbi(Serialize.createInitialTypes(), abi.data);
  static const Scheme = 'esr:';
  static const PlaceholderName = '............1'; // aka uint64(1)
  static const PlaceholderPermission = '............2'; // aka uint64(2)
  static const PlaceholderAuth = {
    'actor': PlaceholderName,
    'permission': PlaceholderPermission,
  };

  static getChainAlias(ChainName name) {
    return name.index + 1;
  }

  static final Map<ChainName, String> ChainIdLookup = {
    ChainName.AMAX:
        '2403d6f602a87977f898aa3c62c79a760f458745904a15b3cd63a106f62adc16',
    ChainName.AMAX_TEST:
        "208dacab3cd2e181c86841613cf05d9c60786c677e4ce86b266d0a58884968f7",
    ChainName.EOS:
        'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906',
    ChainName.EOS_JUNGLE2:
        'e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473',
    ChainName.TELOS:
        '4667b205c6838ef70ff7988f6e8257e8be0e1284a2f59699054a018f743b1d11',
    ChainName.JUNGLE:
        'e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473',
    ChainName.KYLIN:
        '5fff1dae8dc8e2fc4d5b23b2c7665c97f9e9d8edf2b6485a86ba311c25639191',
    ChainName.WORBLI:
        '73647cde120091e0a4b85bced2f3cfdb3041e266cbbe95cee59b73235a1b3b6f',
    ChainName.BOS:
        'd5a3d18fbb3c084e3b1f3fa98c21014b5f3db536cc15d08f9f6479517c6a3d86',
    ChainName.MEETONE:
        'cfe6486a83bad4962f232d48003b1824ab5665c36778141034d75e57b956e422',
    ChainName.INSIGHTS:
        'b042025541e25a472bffde2d62edd457b7e70cee943412b1ea0f044f88591664',
    ChainName.BEOS:
        'b912d19a6abd2b1b05611ae5be473355d64d95aeff0c09bedc8c166cd6468fe4',
    ChainName.WAX:
        '1064487b3cd1a897ce03ae5b6a865651747e2e152090f99c1d19d44e01aea5a4',
    ChainName.PROTON:
        '384da888112027f0321850a169f737c33e53b388aad48b5adace4bab97f437e0',
    ChainName.FIO:
        '21dcae42c0182200e93f954a074011f9048a7624c6fe81d3c9541a614a88bd1c',
    ChainName.EOS_JUNGLE3:
        '2a02a0053e5a8cf73a56ba0fda11e4d92e0238a4a2aa74fccf46d5a910746840'
  };
}
