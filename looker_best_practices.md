# LookML Development Best Practices

Looking for some of the best practices we follow when building in LookML? Here are some helpful tips:

### Naming Convention
 - Follow Looker [naming conventions][1]:
   - Name measures with aggregate function or common terms. `total_[FIELD]` for sum, `count_[FIELD]`, `avg_[FIELD]`, etc.
   - Name ratios descriptively. For example, “Orders Per Purchasing Customers” is clearer than “Orders Percent.”
   - Name yesno fields clearly: “Is Returned” instead of “Returned”
   - Avoid the the words `date` or `time` in a dimension group because Looker appends each timeframe to the end of the dimension name: `created_date` becomes `created_date_date`,`created_date_month`, etc. Simply use `created` which becomes `created_date`, `created_month`, etc.
(More on [timeframes][2])

### Project Organization
- Try to keep one project per connection, with multiple models in each project if they share Views. Use multiple projects per connection when complete isolation of both Models and Views is necessary between git repository and developer teams.
- Review the [`include:`][3] statements, remove Views from models if unnecessary or use the wildcard. For example `include: “user*.view.lookml”` or  `include: “user*.view”` [New LookML] if several user Views (named user_order_facts, users, user_address…) are needed in the model.
- Describe what questions each Explore can answer in the “Documentation” section, using one or many markdown LookML document within each project.

### Model Building
- Envision entire model from high level. Identify the key subject areas users will want to Explore and select Views to include. Joining many to one from the most granular level typically provides the best query performance.
- Comment out extraneous auto-generated Explores in the Model file (using ‘#’ syntax) to reduce clutter when developing, such as those on dimension tables. Explores can be un-commented later as necessary.
- Use the fewest number of Explores possible that allows users to easily get access to the answers they need. Consider splitting out into different Models for different audiences. The optimal number of Explores is different for every business, however many Explores tend to be confusing for the end user.
- Organize Explores across multiple Models to help the end-user find the correct Explore as easily as possible.
- Limit Access Filter Fields to a different model. Use LookML dashboards to make one dashboard work across several models (i.e. remove any `model` parameters from dashboard elements). More on these [here][4] and [here][5].

### Explore Design
- Limit joins in the Explore to only what is necessary to not overwhelm the user when seeing Views in the field picker.
- Use the [`fields:`][6] parameter for each join or at the Explore level to limit the number of dimensions, measures and filters in the field picker.
- Add a short description to each Explore to specify the purpose and audience using the `description:` parameter.
- Avoid joining one View into many Explores unless necessary. If the View has fields that scope to other Views this can cause LookML errors and confuse front-end users. Use the `fields:` parameter to limit this if possible. This also warrants using several View extensions to repeat core fields and add more unique fields for specific Explores.

### Join Design
- Use `sql_on` over `foreign_key` for better readability and LookML flexibility.
Write joins where the base View goes on left to match the relationship parameter, for easy readability.
- Use `${}` unless referring to a date.  For date joins use raw sql (or timeframe [`raw`][7] on Looker 3.32+) to avoid cast/convert_tz in join predicates. However, avoid joining on concatenated primary keys declared in Looker - Join on the base fields from the table for faster queries. More on referencing fields [here][8].
- Always define a relationship using the [`relationship:` parameter][9] to ensure correct aggregates are produced.
- Hard code complex join predicates into map tables (PDTs) to enable faster joins.

### View Design
- Consider the naming, and familiarity of the end user when writing Views. See [Making Views User Friendly][10].
- Declare a [`primary_key`][11] in every View on the field that defines unique rows to ensure accuracy. More on why [here][12].
- Use the [`hidden:`][13] parameter on dimensions that will never be used to avoid confusion (such as join Keys/IDs and compound primary keys, or those designed solely for application use.)
- Describe fields with the description parameter (`description: ‘my great description’`). Typical database column names are not descriptive enough for end users.
- Group together types of measures in the View in a consistent manner. This is stylistic but helps others read your model: Grouping by underlying field (counts then sums then averages etc. ) or all measures together by type (counts together, sums together, etc. ) are common methods.
- Use [sets][14] to organize groups of fields. This makes it easier to remove fields from Explores and makes the model more maintainable.
- Replace count measures of joined-in tables with `count distinct` of the foreign key from the Explore, to avoid unnecessary joins (i.e. user_count = count(distinct orders.user_id)
- Use [`view_label`][15] and [`group_label`][18] parameters to consolidate dimensions and measures from multiple joined Views that fall under the same category.

### PDT usage
- Choose the parameter `sql_trigger_value` over `persist_for` when data should be ready the first time someone runs an explore or on a schedule.
- Evaluate your `sql_trigger_value` schedules such that tables are not building during business hours/replication processes/peak usage times. Trigger the tables late in the night or early in the morning, after ETL is expected to be completed.
- Always define indexes/distkeys/sortkeys to improve query performance.

### Dashboards Organization/Design
- Use the [`html`][17] or [`links`](https://looker.com/docs/reference/field-params/links) parameter in a field to link dashboards (or internal sites) from measures and dimensions
- Single value visualizations are great for highlighting high level KPIs, these do well on the top of the dashboard.

### Source Control
 - Branching Strategy:
   - Please create a branch from the master branch.
   - Commit regularly and with clear commit messages.
   - Each branch should work on a single feature.
   - Open a merge request when you want a review of your code.
   - After approval has been given, merge your code.
 - Personal Branches
   - Do not use peronsal branches for development.
   - All development should be done on feature branches only.
 - Branch Naming
   - naming convention: `branch-type/branch-name``
      - branch-types
        - feature
        - bugFix
        - hotFix
        - refactor
        - test
        - experiment
    - Use kebab case for all branch names.
 - Approval
   - All code should be reviewed by the Lead Developer before merging.
   - All code must be reviewed and approved prior to merging.

  [1]: https://discourse.looker.com/t/naming-fields-for-readability/712
  [2]: https://discourse.looker.com/t/timeframes-and-dimension-groups-in-looker/247
  [3]: http://www.looker.com/docs/reference/model-params/include
  [4]: http://www.looker.com/docs/reference/explore-params/access_filter_fields
  [5]: https://discourse.looker.com/t/access-filter-fields/267
  [6]: http://www.looker.com/docs/reference/explore-params/fields-for-join
  [7]: https://discourse.looker.com/t/using-the-raw-timeframe-3-32/1549
  [8]: https://discourse.looker.com/t/how-to-reference-views-and-fields-in-lookml/179
  [9]: http://www.looker.com/docs/reference/explore-params/relationship
  [10]: https://discourse.looker.com/t/making-views-user-friendly/1328
  [11]: http://www.looker.com/docs/reference/field-reference#primary_key
  [12]: https://discourse.looker.com/t/why-create-lookml-primary-keys/1568
  [13]: http://www.looker.com/docs/reference/field-reference#hidden
  [14]: http://www.looker.com/docs/reference/view-params/sets
  [15]: http://www.looker.com/docs/reference/explore-params/view_label-for-join
  [16]: https://discourse.looker.com/t/differences-between-sql-trigger-value-and-persist-for/479
  [17]: https://discourse.looker.com/t/drill-using-a-sparkline-or-other-images/910
  [18]: https://looker.com/docs/reference/field-params/group_label
