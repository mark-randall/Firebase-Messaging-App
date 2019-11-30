
# Architecture

```

                                            +----------------------+
                                            |                      |
                                            |                      |
                                            |     View (UIKit)     |
                                            |                      |
                                            |                      |
                                            +--+----------------^--+
                                               |                |
                                  User actions |                | ViewState &
                                               |                | ViewEffects
                                               |                |
    +---------------------+                 +--v----------------+--+
    |                     |                 |                      |
    |                     <-----------------+                      |
    |     Coordinator     |   Transition    |      ViewModel       |
    |                     |     screen      |                      |
    |                     |                 |                      |
    +---------------------+                 +--+----------------^--+
          Create VM &                          |                |
         View. Present              Model CRUD |                | App Models
             View.                    requests |                |
                                               |                |
                                            +--v----------------+--+
    ^ View layer may not                    |                      |
    access Coordinator                      |                      |
    director (Done via VM).                 |     Repositories     |
    Coordinator has reference               |                      |
    to View to handle UIKit                 |                      |
                                            +--+----------------^--+
                                               |                |
                                    Model CRUD |                | Data Source
                                               |                | Models
                                               |                |
                                            +--v----------------+--+
                                            |                      |
                                            |     Data Sources     |
                                            |       (External      |
                                            |     integrations)    |
                                            |                      |
                                            +----------------------+


                                            ^ layers are allowed to
                                            access next layer lower
```

