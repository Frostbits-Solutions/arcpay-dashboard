import { h } from 'vue'
import type { ColumnDef } from '@tanstack/vue-table'
import type { TransactionWithListings } from '@/models'
import TransactionsTableAmountCell from '@/components/transactions-table/TransactionsTableAmountCell.vue'
import TransactionsTableTypeCell from '@/components/transactions-table/TransactionsTableTypeCell.vue'
import TransactionsTableIdCell from '@/components/transactions-table/TransactionsTableIdCell.vue'
import TransactionsTableFromCell from '@/components/transactions-table/TransactionsTableFromCell.vue'
import TransactionsTableListingCell from '@/components/transactions-table/TransactionsTableListingCell.vue'
import TransactionsTableDateCell from '@/components/transactions-table/TransactionsTableDateCell.vue'

export const columns: ColumnDef<TransactionWithListings>[] = [
  {
    accessorKey: 'created_at',
    header: () => h('div', { class: 'text-left' }, ''),
    cell: ({ row }) => {
      return h(TransactionsTableDateCell, {row})
    },
  },
  {
    accessorKey: 'type',
    header: () => h('div', { class: 'text-left' }, 'Type'),
    cell: ({ row }) => {
      return h(TransactionsTableTypeCell, {row})
    },
  },
  {
    accessorKey: 'from_address',
    header: () => h('div', { class: 'text-left' }, 'From'),
    cell: ({ row }) => {
      return h(TransactionsTableFromCell, {row})
    },
  },
  {
    accessorKey: 'id',
    header: () => h('div', { class: 'text-left' }, 'Tx Group id'),
    cell: ({ row }) => {
      return h(TransactionsTableIdCell, {row})
    },
  },
  {
    accessorKey: 'listings.name',
    header: () => h('div', { class: 'text-left' }, 'Listing'),
    cell: ({ row }) => {
      return h(TransactionsTableListingCell, {row})
    },
  },
  {
    accessorKey: 'amount',
    header: () => h('div', { class: 'text-left' }, 'Amount'),
    cell: ({ row }) => {
      return h(TransactionsTableAmountCell, {row})
    },
  }
]