import { createApp } from './application'

const { app, router } = createApp()

router.onReady(() => {
  document.addEventListener('DOMContentLoaded', () => {
    var i, element;
    var elements = document.querySelectorAll('#app')
    for (i = 0; i < elements.length; i++) {
  	  app.$mount(elements[i])
    }
  })
})
