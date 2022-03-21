view: order_items {
  sql_table_name: looker_training.order_items ;;

  dimension: id {
    hidden:  yes
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    value_format_name: id
  }

  dimension_group: created {
    description: "When the order was created"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      month_num,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: reporting_period {
    description: "This Year to date versus Last Year to date"
    group_label: "Created Date"
    sql:  CASE
              WHEN EXTRACT(year FROM ${created_raw}) = EXTRACT(year FROM current_timestamp())
              AND ${created_raw} < current_timestamp()
              THEN 'This Year to Date'

              WHEN  EXTRACT(year FROM ${created_raw}) + 1 =  EXTRACT(year FROM current_timestamp())
              AND EXTRACT(DAYOFYEAR FROM ${created_raw}) <= EXTRACT(DAYOFYEAR FROM current_timestamp())
              THEN 'Last Year to Date'
          END ;;
  }

  dimension: months_since_signup {
    description: "Time between current order and when that user was created"
    type: number
    sql: DATEDIFF('month',${users.created_raw},${created_raw}) ;;
  }

  dimension_group: delivered {
    description: "When the order was delivered"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: returned {
    description: "When the order was returned"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped {
    description: "When the order was shipped"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: shipping_time {
    description: "Shipping time in days"
    type: number
    sql: DATEDIFF(day, ${order_items.shipped_date}, ${order_items.delivered_date}) ;;
  }

  dimension: sale_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.sale_price ;;
  }

  dimension: gross_margin {
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  dimension: status {
    description: "Whether order is processing, shipped, completed, etc."
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: inventory_item_id {
    hidden:  yes
    type: number
    sql: ${TABLE}.inventory_item_id ;;
    value_format_name: id
  }

  dimension: order_id {
    hidden:  yes
    type: number
    sql: ${TABLE}.order_id ;;
    value_format_name: id
  }

  dimension: user_id {
    hidden: yes
    type: number
    sql: ${TABLE}.user_id ;;
    value_format_name: id
  }

  dimension: profit {
    description: "Profit made on any one item"
    hidden:  yes
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

## MEASURES ##

  measure: order_item_count {
    type: count
    drill_fields: [detail*]
  }

  measure: order_count {
    description: "A count of unique orders"
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [detail*]
  }

  measure: total_sale_price {
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: average_sale_price {
    type: average
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: average_spend_per_user {
    type: number
    sql: ${total_sale_price}*1.0/nullif(${users.count},0) ;;
    value_format_name: usd
  }

  measure: total_sale_price_completed {
    label: "Total Sale Price from Completed Orders"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: status
      value: "Complete"
    }
  }

  measure: total_sale_price_returned {
    label: "Total Sale Price Lost from Returns"
    description: "Sales not gained due to the ordered item being returned by the customer"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: returned_date
      value: "-NULL"
    }
  }

  measure: total_profit {
    type: sum
    sql: ${profit} ;;
    value_format_name: usd
  }

  measure: profit_margin {
    type: number
    sql: ${total_profit}/NULLIF(${total_sale_price}, 0) ;;
    value_format_name: percent_2
  }

    measure: total_gross_margin {
    type: sum
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  measure: average_shipping_time {
    type: average
    sql: ${shipping_time} ;;
    value_format: "0.00\" days\""
  }

# ----- Sets of fields for drilling ------
  set: detail {
    fields: [id, order_id, status, created_date, sale_price, products.brand, products.item_name, users.portrait, users.first_name, users.last_name, users.email]
  }
}
