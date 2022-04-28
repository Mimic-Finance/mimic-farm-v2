import { useState, useEffect, useCallback } from "react";
import Web3 from "web3";
import CountUp from "react-countup";
import { useAutoCompound } from "hooks/useContracts";
import { Text, Box } from "@chakra-ui/react";

const TVD = () => {
  const AutoCompound = useAutoCompound();
  const [tvd, setTVD] = useState(0);

  const loadTVD = useCallback(async () => {
    const _tvd = await AutoCompound.methods
      .getStakingBalance()
      .call();
    setTVD(Web3.utils.fromWei(_tvd.toString()));
  }, [AutoCompound]);

  useEffect(() => {
    loadTVD();
  }, [loadTVD]);

  return (
    <>
      {tvd > 0 && (
        <Box>
          <Text fontSize="xl">
            <b>Total Value Deposited</b>
          </Text>
          <Text fontSize={{ base: "3xl", md: "5xl", lg: "5xl" }}>
            <CountUp duration={2} end={tvd} separator="," />
            <font size="6">{" JUSD"}</font>
          </Text>
        </Box>
      )}
    </>
  );
};

export default TVD;
