--Exercise 1 — Model Design

--1. What relationships should Comment have?
--The Comment entity should be linked to both Task and User, since every comment is written by a user and attached to a specific task.

--2. Should Task have a comments relationship?
--Yes. A single task can accumulate multiple comments over time, making a one-to-many relationship appropriate.

--3. What should happen to comments when a task is deleted?
--The associated comments should be removed automatically to prevent orphan records and maintain database consistency.

class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True)
    task_id = Column(Integer, ForeignKey("tasks.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    content = Column(Text, nullable=False)
    created_at = Column(
        DateTime,
        server_default=func.current_timestamp()
    )

    task = relationship("Task", back_populates="comments")
    user = relationship("User")

    def __repr__(self):
        return f"<Comment {self.id}>"

comments = relationship(
    "Comment",
    back_populates="task",
    cascade="all, delete-orphan"
)



-- Exercise 2 — Migration Creation

Questions

--1. What does upgrade() do?
--The upgrade() function applies the schema modifications defined in the migration. In this case, it creates the new comments table and its constraints.

--2. What does downgrade() do?
--It reverses the migration by undoing the changes introduced in upgrade().

--3. What happens if you downgrade this migration?
--The database returns to its previous version, meaning the comments table is removed and any rows stored in it are lost.

--BONUS
CheckConstraint("content <> ''", name="ck_comment_content")



-- Exercise 3 — CRUD Challenge

with Session(engine) as session:

    # Create team
    devops = Team(
        name="DevOps",
        description="Operations and deployment team"
    )

    session.add(devops)
    session.commit()

    print("✓ Team registered")


    # Create user
    diana = User(
        username="diana_ops",
        email="diana@example.com",
        full_name="Diana Rodriguez",
        team=devops
    )

    session.add(diana)
    session.commit()

    print("✓ User registered")


    # Create tasks
    tasks = [
        Task(
            title="Implement CI/CD",
            description="Automate deployment pipeline",
            status="high",
            assignee=diana
        ),
        Task(
            title="Server Monitoring",
            description="Configure monitoring tools",
            status="medium",
            assignee=diana
        ),
        Task(
            title="Archive Old Logs",
            description="Remove outdated log files",
            status="low",
            assignee=diana
        )
    ]

    session.add_all(tasks)
    session.commit()

    print("✓ Tasks added")


    # Count tasks
    total_tasks = session.query(Task).count()
    print(f"Current task count: {total_tasks}")


    # Close a task
    tasks[0].status = "closed"
    session.commit()

    print(f"✓ Closed task: {tasks[0].title}")


    # Delete lowest-priority task
    session.delete(tasks[2])
    session.commit()

    print(f"✓ Removed task: {tasks[2].title}")



-- Exercise 4 — Migration Rollback

--Questions

--1. What happens to the column?
--Rolling back the migration removes the estimated_hours column from the table schema.

--2. What happens to the data?
--Any values stored in that column are discarded because the column itself no longer exists after the rollback.



--Exercise 5 — Concept Check

--1. Why use ORM instead of raw SQL?
--An ORM allows developers to interact with database records as Python objects, reducing repetitive SQL code and improving maintainability.

--2. Why use migrations?
--Migrations provide a structured way to track and apply schema changes across different environments while preserving version history.

--3. When would you rollback?
--A rollback is useful when a migration introduces unexpected issues, breaks functionality, or needs to be reverted for stability reasons.

--4. Difference between add() and commit()?
--add() places an object into the current session, while commit() permanently writes all pending session changes to the database.

--5. Why are relationships useful?
--Relationships simplify access between related entities and allow SQLAlchemy to manage joins and associations automatically.