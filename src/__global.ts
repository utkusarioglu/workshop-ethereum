declare global {
  namespace NodeJS {
    interface ProcessEnv {
      INFURA_API_KEY?: string;
      COINMARKETCAP_API_KEY?: string;
      ETHERSCAN_API_KEY?: string;
      LOCAL_GETH_INSTANCE_URL?: string;
    }
  }

  // namespace c {
  //   interface IConfig {
  //     goerli: string;
  //   }
  // }
  // var c: c.IConfig;

  // namespace c {
  //   interface IConfig {
  //     goerli: string;
  //   }
  // }
}

export default {};
