import { Text, Box, Button, IconButton } from "@chakra-ui/react";
import { Image } from "@chakra-ui/react";
import Link from "next/link";
import { FaGavel, FaRegChartBar } from "react-icons/fa";

export const Pool = (props) => {
  return (
    <Box
      p={10}
      style={{ borderRadius: 10, color: "#000000", position: "relative" }}
      bg={props.color}
    >
      <Image
        src={"/assets/images/pools/" + props.label + ".png"}
        alt={props.label}
        className="pool-logo"
        width={100}
      />
      <Text fontWeight="bold" fontSize="2xl">
        {props.poolName}
      </Text>
      {props.description}
      <Text pt={3}>{props.token}</Text>
      <Text pt={3} fontWeight="bold">
        APY : {props.apy} %
      </Text>
      <Link href={"/farm/" + props.label} passHref>
        <Button
          leftIcon={<FaGavel />}
          mt={4}
          style={{ backgroundColor: "#232137", color: "#fff" }}
          width={200}
          variant="solid"
        >
          Stake Pool
        </Button>
      </Link>
      <Link href={"/auto/" + props.label} passHref>
        <Button
          ml={5}
          leftIcon={<FaRegChartBar />}
          mt={4}
          style={{ backgroundColor: "#232137", color: "#fff" }}
          width={200}
          variant="solid"
        >
          Auto Compound
        </Button>
      </Link>
    </Box>
  );
};
