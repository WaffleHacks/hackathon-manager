SimpleForm.setup do |config|
  config.wrappers :bootstrap_horizontal_boolean_alternate, tag: 'div', class: 'form-group', error_class: 'form-group-invalid' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :grid_wrapper, tag: 'div', class: 'ml-5' do |wr|
      wr.wrapper :form_check_wrapper, tag: 'div', class: 'form-check' do |bb|
        bb.use :input, class: 'form-check-input', error_class: 'is-invalid'
        bb.use :label, class: 'form-check-label'
        bb.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback d-block' }
        bb.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
      end
    end
  end
end
