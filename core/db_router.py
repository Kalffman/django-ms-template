
class DatabaseRouter:

    apps = {'sessions'}

    def db_for_read(self, model, **hints):
        app = model._meta.app_label

        if app in self.apps:
            return 'default'

        return None

    def db_for_write(self, model, **hints):
        app = model._meta.app_label

        if app in self.apps:
            return 'default'

        return None

    def allow_relation(self, obj1, obj2, **hints):
        if obj1._meta.app_label in self.apps or obj2._meta.app_label in self.apps:
            return True

        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):

        if app_label in self.apps:
            return db == 'default'

        return None
