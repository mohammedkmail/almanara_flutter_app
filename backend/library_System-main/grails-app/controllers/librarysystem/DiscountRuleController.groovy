package librarysystem

import grails.plugin.springsecurity.annotation.Secured

@Secured(['ROLE_ADMIN'])
class DiscountRuleController {

    static allowedMethods = [save: 'POST', update: 'PUT', delete: 'DELETE']

    def index() {
        respond DiscountRule.list(sort: 'priority', order: 'asc')
    }

    def create() { respond new DiscountRule(active: true, priority: 100) }

    def save(DiscountRule rule) {
        if (!rule) { notFound(); return }
        if (!rule.validate()) { render view: 'create', model: [discountRule: rule]; return }
        rule.save(flush: true, failOnError: true)
        flash.message = 'تمت إضافة قاعدة الخصم.'
        redirect action: 'index'
    }

    def edit(Long id) {
        DiscountRule rule = DiscountRule.get(id)
        if (!rule) { notFound(); return }
        respond rule
    }

    def update(DiscountRule rule) {
        if (!rule) { notFound(); return }
        if (!rule.validate()) { render view: 'edit', model: [discountRule: rule]; return }
        rule.save(flush: true, failOnError: true)
        flash.message = 'تم تحديث قاعدة الخصم.'
        redirect action: 'index'
    }

    def delete(Long id) {
        DiscountRule rule = DiscountRule.get(id)
        if (!rule) { notFound(); return }
        rule.delete(flush: true)
        flash.message = 'تم حذف قاعدة الخصم.'
        redirect action: 'index'
    }

    protected void notFound() { flash.message = 'قاعدة الخصم غير موجودة.'; redirect action: 'index' }
}
