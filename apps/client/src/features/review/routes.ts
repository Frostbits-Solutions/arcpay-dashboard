import ListingReviewView from './views/ListingReviewView.vue'
import SaleReview from './components/SaleReview.vue'
import AuctionReview from './components/AuctionReview.vue'
import DutchReview from './components/DutchReview.vue'

export default {
  path: '/review',
  name: 'listing-review',
  component: ListingReviewView,
  meta: {
    closeable: true
  },
  children: [
    {
      path: '/sale',
      name: 'sale-review',
      component: SaleReview
    },
    {
      path: '/auction',
      name: 'auction-review',
      component: AuctionReview
    },
    {
      path: '/dutch',
      name: 'dutch-review',
      component: DutchReview
    }
  ]
}