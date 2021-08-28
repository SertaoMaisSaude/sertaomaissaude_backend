import os

from django import forms


def createPathMessageFile(instance, filename):
    directory = 'chat/' + str(instance.chat.id) + '/message/' + str(instance.id)
    full_path = str(directory) + "/%s" % (filename)
    return full_path


def createPathPhotoHealthTips(instance, filename):
    directory = 'health_tips/' + str(instance.id)
    full_path = str(directory) + "/%s" % (filename)
    return full_path

def createPathPhotoTeamMember(instance, filename):
    directory = 'team_member/' + str(instance.id)
    full_path = str(directory) + "/%s" % (filename)
    return full_path


def createPathPhotoLogPost(instance, filename):
    directory = 'blog_post/' + str(instance.id)
    full_path = str(directory) + "/%s" % (filename)
    return full_path

def createPathAppVersion(instance, filename):
    directory = 'app_version/' + str(instance.id)
    full_path = str(directory) + "/%s" % (filename)
    return full_path


def adiciona_form_control(self):
    for field_name, field in self.fields.items():
        if field and isinstance(field, forms.ModelChoiceField):
            field.widget.attrs['class'] = 'selectpicker form-control'
            field.widget.attrs['data-live-search'] = 'true'
            field.widget.attrs['data-provide'] = 'selectpicker'
            field.widget.attrs['data-size '] = '10'
        elif field and isinstance(field, forms.TypedChoiceField):
            field.widget.attrs['class'] = 'selectpicker form-control'
            field.widget.attrs['data-live-search'] = 'true'
            field.widget.attrs['data-provide'] = 'selectpicker'
            field.widget.attrs['data-size '] = '10'
        elif field and isinstance(field, forms.ModelMultipleChoiceField):
            field.widget.attrs['class'] = 'selectpicker form-control'
            field.widget.attrs['data-live-search'] = 'true'
            field.widget.attrs['data-provide'] = 'selectpicker'
            field.widget.attrs['data-size '] = '10'
            field.widget.attrs['multiple'] = 'true'
        elif field and isinstance(field, forms.DateField):
            field.widget.attrs['data-provide'] = 'datepicker2'
            field.widget.attrs['class'] = 'form-control datepicker2'
        elif field and isinstance(field, forms.DateTimeField):
            field.widget.attrs['data-provide'] = 'datepicker2'
            field.widget.attrs['class'] = 'form-control datepicker2'
        elif field and isinstance(field, forms.TimeField):
            field.widget.attrs['class'] = 'form-control'
            field.widget.attrs['data-provide'] = 'timepicker'
            field.widget.attrs['data-show-meridian'] = 'false'
        # elif field and isinstance(field, forms.BooleanField):
        #     field.widget.attrs['class'] = 'custom-control-input'
        else:
            field.widget.attrs['class'] = 'form-control'
        if field.required:
            field.label = field.label + '*'
