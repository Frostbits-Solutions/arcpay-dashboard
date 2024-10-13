import { h } from 'vue'
import type { ColumnDef } from '@tanstack/vue-table'
import type { CompositeListing } from '@/models'
import ListingsTableStatusCell from '@/components/listings-table/ListingsTableStatusCell.vue'
import ListingsTableAssetCell from '@/components/listings-table/ListingsTableAssetCell.vue'
import ListingsTableTypeCell from '@/components/listings-table/ListingsTableTypeCell.vue'
import ListingsTableSellerCell from '@/components/listings-table/ListingsTableSellerCell.vue'
import ListingsTableIdCell from '@/components/listings-table/ListingsTableIdCell.vue'
import ListingsTableActionCell from '@/components/listings-table/ListingsTableActionCell.vue'

export const columns: ColumnDef<CompositeListing>[] = [
  {
    accessorKey: 'status',
    header: () => h('div', { class: 'text-left' }, 'Status'),
    cell: ({ row }) => {
      return h(ListingsTableStatusCell, {row})
    },
  },
  {
    accessorKey: 'id',
    header: () => h('div', { class: 'text-left' }, 'Id'),
    cell: ({ row }) => {
      return h(ListingsTableIdCell, {row})
    },
  },
  {
    accessorKey: 'type',
    header: () => h('div', { class: 'text-left' }, 'Type'),
    cell: ({ row }) => {
      return h(ListingsTableTypeCell, {row})
    },
  },
  {
    accessorKey: 'asset_id',
    header: () => h('div', { class: 'text-left' }, 'Asset'),
    cell: ({ row }) => {
      return h(ListingsTableAssetCell, {row})
    },
  },
  {
    accessorKey: 'seller_address',
    header: () => h('div', { class: 'text-left' }, 'Seller'),
    cell: ({ row }) => {
      return h(ListingsTableSellerCell, {row})
    },
  },
  {
    accessorKey: 'actions',
    header: () => h('div', { class: 'text-left' }, ''),
    cell: ({ row }) => {
      return h(ListingsTableActionCell, {row})
    },
  }
]