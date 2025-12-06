import ListingCreationView from './views/ListingCreationView.vue'
import OnchainCreation from './components/OnchainCreation.vue'
import SaleCreation from './components/SaleCreation.vue'
import AuctionCreation from './components/AuctionCreation.vue'
import DutchCreation from './components/DutchCreation.vue'
import OffchainCreation from './components/OffchainCreation.vue'

export default {
  path: '/create',
  name: 'listing-creation',
  component: ListingCreationView,
  meta: {
    title: 'Create listing',
    closeable: true
  },
  redirect: {name: 'sale-creation'},
  children: [
    {
      path: '/onchain',
      name: 'onchain-creation',
      meta: {
        description: 'Create a new digital on-chain asset listing',
      },
      component: OnchainCreation,
      children: [
        {
          path: '/sale',
          name: 'sale-creation',
          component: SaleCreation
        },
        {
          path: '/auction',
          name: 'auction-creation',
          component: AuctionCreation
        },
        {
          path: '/dutch',
          name: 'dutch-creation',
          component: DutchCreation
        }
      ]
    },
    {
      path: '/offchain',
      name: 'offchain-creation',
      component: OffchainCreation,
      meta: {
        description: 'Create a new off-chain asset listing',
      },
    }
  ]
}