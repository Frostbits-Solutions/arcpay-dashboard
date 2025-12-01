import algosdk from "algosdk";
import type { AssetMetadata } from "@/types";
import voi from "@/voi";
import algo from "@/algo";

export interface NetworkServices {
  getAddressAssets: (
    algodClient: algosdk.Algodv2,
    address: string,
    page?: number,
    size?: number,
  ) => Promise<AssetMetadata[]>;
  getCreatedAppId: (
    algodClient: algosdk.Algodv2,
    txId: string,
  ) => Promise<number>;
  getExplorerLink: (objectId: string) => string;
}

export const services: Record<string, NetworkServices> = {
  "voi:testnet": {
    getAddressAssets: (
      algodClient: algosdk.Algodv2,
      address: string,
      page?: number,
      size?: number,
    ) => voi.getAddressAssets(algodClient, address, "voi:testnet", page, size),
    getCreatedAppId: (algodClient: algosdk.Algodv2, txId: string) =>
      voi.getCreatedAppId(algodClient, txId, "voi:testnet"),
    getExplorerLink: (objectId: string) =>
      voi.getExplorerLink("voi:testnet", objectId),
  },
  "voi:mainnet": {
    getAddressAssets: (
      algodClient: algosdk.Algodv2,
      address: string,
      page?: number,
      size?: number,
    ) => voi.getAddressAssets(algodClient, address, "voi:mainnet", page, size),
    getCreatedAppId: (algodClient: algosdk.Algodv2, txId: string) =>
      voi.getCreatedAppId(algodClient, txId, "voi:mainnet"),
    getExplorerLink: (objectId: string) =>
      voi.getExplorerLink("voi:mainnet", objectId),
  },
  "algo:testnet": {
    getAddressAssets: (
      algodClient: algosdk.Algodv2,
      address: string,
      page?: number,
      size?: number,
    ) => algo.getAddressAssets(algodClient, address, page, size),
    getCreatedAppId: (algodClient: algosdk.Algodv2, txId: string) =>
      algo.getCreatedAppId(algodClient, txId, "algo:testnet"),
    getExplorerLink: (objectId: string) =>
      algo.getExplorerLink("algo:testnet", objectId),
  },
  "algo:mainnet": {
    getAddressAssets: (
      algodClient: algosdk.Algodv2,
      address: string,
      page?: number,
      size?: number,
    ) => algo.getAddressAssets(algodClient, address, page, size),
    getCreatedAppId: (algodClient: algosdk.Algodv2, txId: string) =>
      algo.getCreatedAppId(algodClient, txId, "algo:mainnet"),
    getExplorerLink: (objectId: string) =>
      algo.getExplorerLink("algo:mainnet", objectId),
  },
};
