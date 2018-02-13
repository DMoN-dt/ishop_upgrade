// 'use strict'

import Vue from 'vue'
import ModalDialogs, { makeDialog } from 'vue-modal-dialogs'

import AppLogin from './dialogs/login'
import AppConfirm from './dialogs/confirm'
import AppMessageBox from './dialogs/message-box'

// Initialize ModalDialogs
Vue.use(ModalDialogs)

// Make serval dialog functions
export const loginDialog = makeDialog(AppLogin)
export const confirmDialog = makeDialog(AppConfirm)
export const messageBoxDlg = makeDialog(AppMessageBox, 'content')

Vue.prototype.$confirmDialog = confirmDialog
Vue.prototype.$loginDialog = loginDialog
Vue.prototype.$messageBox = messageBoxDlg
