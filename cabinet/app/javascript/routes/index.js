import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

import Cabinet_Component_View from '../components/cabinet/component.vue'
import Cabinet_Index_View from '../components/cabinet/index.vue'

import Cabinet_Ecommerce_Component_View from '../components/cabinet/ecommerce/component.vue'

import Cabinet_Ecommerce_Sellers_Component_View from '../components/cabinet/ecommerce/seller/root_component.vue'
import Cabinet_Ecommerce_Sellers_List_View from '../components/cabinet/ecommerce/seller/list.vue'

import Cabinet_Ecommerce_Seller_Component_View from '../components/cabinet/ecommerce/seller/item_component.vue'
import Cabinet_Ecommerce_Seller_View from '../components/cabinet/ecommerce/seller/index.vue'
import Cabinet_Ecommerce_Seller_ProductsGroups_Index_View from '../components/cabinet/ecommerce/seller/products_groups/index.vue'

import Cabinet_Ecommerce_Seller_Products_Component_View from '../components/cabinet/ecommerce/seller/products/root_component.vue'
import Cabinet_Ecommerce_Seller_Products_Index_View from '../components/cabinet/ecommerce/seller/products/index.vue'
import Cabinet_Ecommerce_Seller_Products_Item_View from '../components/cabinet/ecommerce/seller/products/item.vue'

	
export function AppRouter() {
  return new VueRouter({
    mode: 'history',
    routes: [
	  {path: '/', redirect: '/cabinet'},
	  {
		path: '/cabinet', component: Cabinet_Component_View,
		meta: {notRequiresAuth: true, breadcrumb: {textI18n: 'cabinet.bcb_title'}},
		children: [
		  {path: '', component: Cabinet_Index_View},
		  {
			path: 'ecommerce', component: Cabinet_Ecommerce_Component_View,
			meta: {breadcrumb: {textI18n: 'cabinet.bcb_ecommerce'}},
			children: [{
			
			path: '/cabinet/sellers', component: Cabinet_Ecommerce_Sellers_Component_View,
			children: [
			  {path: '', component: Cabinet_Ecommerce_Sellers_List_View, meta: {breadcrumb: {textI18n: 'cabinet.bcb_sellers'}}},
			  {
				path: ':seller_id', component: Cabinet_Ecommerce_Seller_Component_View,
				meta: {breadcrumb: {titleGetter: 'activeSellerName', textLoadingI18n: 'seller.bcb_title', hideOnEstore: false}},
				props: (route) => ({seller_id: Number(route.params.seller_id)}),
				children: [
			  	  {path: '', component: Cabinet_Ecommerce_Seller_View},
			  	  {
					path: 'prodgroups', component: Cabinet_Ecommerce_Seller_ProductsGroups_Index_View,
					meta: {breadcrumb: {textI18n: 'seller.prodgroups.bcb_title'}}
				  },
				  {
					path: 'prodgroups/:prodgroup_id/products', component: Cabinet_Ecommerce_Seller_Products_Component_View,
					meta: {breadcrumb: {textI18n: 'seller.products.bcb_title'}},
					props: (route) => ({prodgroup_id: Number(route.params.prodgroup_id)}),
					children: [
					  {path: '', component: Cabinet_Ecommerce_Seller_Products_Index_View},
					  {
					    path: ':product_id', component: Cabinet_Ecommerce_Seller_Products_Item_View,
					    meta: {breadcrumb: {textI18n: 'seller.products.bcb_item_title'}},
						props: (route) => ({product_id: Number(route.params.product_id)})
					  }
					]
				  }
			    ]
			  }
			]
			
			
			}]
		  }
		]
	  },

      //{path: '/admin', component: () => import('../components/news/news_edit.vue')},
	  // {path: '/404', component: NotFound},
	  // {path: '*', redirect: "/404"}
    ]
  })
}
