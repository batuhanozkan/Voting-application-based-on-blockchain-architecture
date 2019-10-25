// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import VueRouter from 'vue-router'
import Buefy from "buefy";
import "@fortawesome/fontawesome-free/css/all.css";
import "@fortawesome/fontawesome-free/css/fontawesome.css";
import VueSwal from 'vue-swal'

import 'buefy/dist/buefy.css'

import config from 'buefy/src/utils/config'
config.defaultIconPack = 'fas';

import Welcome from './components/Welcome'
import Create from './components/Create'
import Result from './components/Result'
import Vote from './components/Vote'
import { format } from 'date-fns'

Vue.config.productionTip = false
Vue.use(VueRouter)
Vue.use(VueSwal)
Vue.use(Buefy, {
  defaultIconPack: "fas",
  defaultDateFormatter: date => {
    return format(date, 'D/M/YYYY');
  },
  defaultDateParser: date => {
    console.log("Default date parser işlendi:", date)
    return date;
  }
});

//define routes
const routes = [
  { path: '/', component: Welcome, name: "home" },
  { path: '/create', component: Create, name: "create" },
  { path: '/vote', component: Vote, name: "vote" },
  { path: '/result', component: Result, name: "result" },
]

const router = new VueRouter({
  routes, // short for routes: routes
  mode: 'history'
})

new Vue({
  el: '#app',
  components: { App },  
  template: '<App/>',
  router
})
