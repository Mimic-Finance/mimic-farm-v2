import { createContext, useEffect, useState, useCallback } from "react";
import { useWhitelisted } from "hooks/useFunctions";
import { Text, Center, Box } from "@chakra-ui/react";
import { WarningIcon } from "@chakra-ui/icons";

export const PoolContext = createContext(false);

export const PoolContextProvider = ({ children, address }) => {
  const getWhitelisted = useWhitelisted();
  const [whitelist, setWhitelisted] = useState([]);
  const [accessible, setAccessible] = useState(false);

  const checkOpenPool = useCallback(async () => {
    const open = whitelist.filter((whitelist) => address === whitelist.address);
    if (open.length > 0) {
      setAccessible(true);
    }
  }, [whitelist, address]);

  useEffect(() => {
    setWhitelisted(getWhitelisted);
  }, [getWhitelisted]);

  useEffect(() => {
    if (whitelist.length > 0) {
      checkOpenPool();
    }
  }, [checkOpenPool, whitelist.length]);

  if (accessible) {
    return <PoolContext.Provider>{children}</PoolContext.Provider>;
  } else {
    return (
      <PoolContext.Provider>
        <>
          <Center>
            <WarningIcon w={20} h={20} mt={10} mb={5} />
          </Center>
          <Box style={{ textAlign: "center" }}>
            <Text fontSize="4xl">ยังไม่เปิดให้ฟาร์มจร้าาาาาาาา</Text>
            <Text>ถ้าอยากให้เปิด ก็มาดิ</Text>
          </Box>
        </>
      </PoolContext.Provider>
    );
  }
};